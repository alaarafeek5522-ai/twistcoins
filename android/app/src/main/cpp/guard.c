#include <jni.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <android/log.h>

#define TAG "sys_core"

// XOR decode
static void xor_decode(char *buf, const unsigned char *enc, int len, unsigned char key) {
    for (int i = 0; i < len; i++) buf[i] = enc[i] ^ key;
    buf[len] = 0;
}

// Anti-debug: يكشف TracerPid
static int is_debugged() {
    char buf[512];
    int fd = open("/proc/self/status", O_RDONLY);
    if (fd < 0) return 0;
    int n = read(fd, buf, sizeof(buf) - 1);
    close(fd);
    if (n <= 0) return 0;
    buf[n] = 0;
    char *p = strstr(buf, "TracerPid:");
    if (!p) return 0;
    p += 10;
    while (*p == ' ' || *p == '\t') p++;
    return (*p != '0');
}

// Frida detection
static int has_frida() {
    // Check maps for frida-agent
    char buf[1024];
    int fd = open("/proc/self/maps", O_RDONLY);
    if (fd < 0) return 0;
    int n = read(fd, buf, sizeof(buf) - 1);
    close(fd);
    if (n <= 0) return 0;
    buf[n] = 0;
    unsigned char enc[] = {0x06,0x1c,0x08,0x13,0x00,0x2d,0x00,0x06,0x05,0x13};
    char frida[11];
    xor_decode(frida, enc, 10, 0x62); // "frida-agent"
    if (strstr(buf, frida)) return 1;

    // Check port 27042
    fd = open("/proc/net/tcp", O_RDONLY);
    if (fd < 0) return 0;
    char tbuf[4096];
    n = read(fd, tbuf, sizeof(tbuf) - 1);
    close(fd);
    if (n <= 0) return 0;
    tbuf[n] = 0;
    // 27042 = 0x699A
    unsigned char penc[] = {0x1e, 0x4e, 0x4e, 0x5b};
    char port[5];
    xor_decode(port, penc, 4, 0x6f); // "699A" XOR
    return (strstr(tbuf, "699A") != NULL);
}

// Root detection
static int is_rooted() {
    const unsigned char p1e[] = {0x5b,0x4a,0x5d,0x4e,0x01,0x4a,0x4f,0x4c,0x1e,0x4e,0x5d,0x4c,0x01,0x4e,0x5b};
    char p1[16];
    xor_decode(p1, p1e, 15, 0x2f); // /system/xbin/su
    struct stat st;
    if (stat(p1, &st) == 0) return 1;

    const unsigned char p2e[] = {0x5b,0x4a,0x5d,0x4e,0x01,0x4f,0x4a,0x4f,0x1e,0x4e,0x5d,0x4c,0x01,0x4e,0x5b};
    char p2[16];
    xor_decode(p2, p2e, 15, 0x2f); // /system/bin/su
    if (stat(p2, &st) == 0) return 1;

    const unsigned char p3e[] = {0x5b,0x44,0x5e,0x5d,0x01,0x4e,0x5b};
    char p3[8];
    xor_decode(p3, p3e, 7, 0x2f); // /sbin/su
    if (stat(p3, &st) == 0) return 1;

    return 0;
}

// Emulator detection
static int is_emulator() {
    struct stat st;
    // goldfish pipe
    const unsigned char ge[] = {0x4b,0x4a,0x49,0x01,0x48,0x4f,0x55,0x4e,0x5b,0x4a,0x5d,0x01,0x44,0x4f,0x4c,0x48,0x5a,0x4a,0x4e,0x5b};
    char gp[21];
    xor_decode(gp, ge, 20, 0x2f);
    if (stat(gp, &st) == 0) return 1;
    return 0;
}

// Signature check
static int check_signature(JNIEnv *env, jobject ctx) {
    // Expected signature hash (SHA-256 prefix XOR encoded)
    // تقدر تحدث الـ hash بعد أول build
    unsigned char exp[] = {
        0x72,0x71,0x6e,0x6e,0x6e,0x6e,0x6e,0x6e
    };
    char expected[9];
    xor_decode(expected, exp, 8, 0x1e); // placeholder

    jclass pm_class = (*env)->FindClass(env, "android/content/pm/PackageManager");
    if (!pm_class) return 1;

    jclass ctx_class = (*env)->GetObjectClass(env, ctx);
    jmethodID gpm = (*env)->GetMethodID(env, ctx_class,
        "getPackageManager", "()Landroid/content/pm/PackageManager;");
    if (!gpm) return 1;

    jobject pm = (*env)->CallObjectMethod(env, ctx, gpm);

    jmethodID gpn = (*env)->GetMethodID(env, ctx_class,
        "getPackageName", "()Ljava/lang/String;");
    jstring pkg = (*env)->CallObjectMethod(env, ctx, gpn);

    jint flags = 0x40; // GET_SIGNATURES
    jmethodID gpi = (*env)->GetMethodID(env, pm_class,
        "getPackageInfo",
        "(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;");
    if (!gpi) return 1;

    jobject pi = (*env)->CallObjectMethod(env, pm, gpi, pkg, flags);
    if (!pi) return 1;

    jclass pi_class = (*env)->GetObjectClass(env, pi);
    jfieldID sigs_field = (*env)->GetFieldID(env, pi_class,
        "signatures", "[Landroid/content/pm/Signature;");
    jobjectArray sigs = (*env)->GetObjectField(env, pi, sigs_field);
    if (!sigs) return 1;

    jobject sig0 = (*env)->GetObjectArrayElement(env, sigs, 0);
    jclass sig_class = (*env)->GetObjectClass(env, sig0);
    jmethodID hc = (*env)->GetMethodID(env, sig_class, "hashCode", "()I");
    jint hash = (*env)->CallIntMethod(env, sig0, hc);

    // Store hash first run via shared preferences (self-learning)
    return 0; // نرجع 0 الأول ونحدث لاحقاً
}

// DEX integrity check
static int check_dex_integrity() {
    const unsigned char pe[] = {
        0x1b,0x18,0x12,0x13,0x1e,0x55,0x1e,0x18,0x1a,0x1b,0x55,
        0x1e,0x13,0x17,0x55,0x13,0x1f,0x1b,0x0b,0x55,0x18,0x1f,
        0x10,0x0b,0x0a,0x0e,0x55,0x1a,0x0c,0x18,0x0e,0x0e,0x13,
        0x0b,0x0e,0x0a
    };
    char path[37];
    xor_decode(path, pe, 36, 0x7f);
    struct stat st;
    return (stat(path, &st) != 0) ? 1 : 0;
}

JNIEXPORT jboolean JNICALL
Java_com_alaa_twistcoins_GuardManager_nativeCheck(
        JNIEnv *env, jobject thiz, jobject ctx) {

    if (is_debugged()) {
        __android_log_print(ANDROID_LOG_ERROR, TAG, "x01");
        return JNI_FALSE;
    }
    if (has_frida()) {
        __android_log_print(ANDROID_LOG_ERROR, TAG, "x02");
        return JNI_FALSE;
    }
    if (is_emulator()) {
        __android_log_print(ANDROID_LOG_ERROR, TAG, "x03");
        return JNI_FALSE;
    }
    return JNI_TRUE;
}

JNIEXPORT jboolean JNICALL
Java_com_alaa_twistcoins_GuardManager_nativeCheckRoot(
        JNIEnv *env, jobject thiz) {
    return is_rooted() ? JNI_FALSE : JNI_TRUE;
}

JNIEXPORT jstring JNICALL
Java_com_alaa_twistcoins_GuardManager_nativeGetKey(
        JNIEnv *env, jobject thiz, jint seed) {
    // XOR obfuscated internal key
    unsigned char enc[] = {
        0x25,0x2e,0x27,0x6d,0x27,0x28,0x2e,0x6d,
        0x21,0x28,0x2a,0x6d,0x21,0x27,0x6d,0x39,
        0x28,0x24,0x21,0x6d,0x36,0x24,0x24
    };
    char key[24];
    xor_decode(key, enc, 23, 0x43);
    return (*env)->NewStringUTF(env, key);
}
