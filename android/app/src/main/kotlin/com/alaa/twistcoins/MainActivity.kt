package com.alaa.twistcoins

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.PackageManager
import android.os.Build

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.alaa.twistcoins/security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getSignature") {
                try {
                    val sig = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        val info = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES)
                        val sigBytes = info.signingInfo.apkContentsSigners[0].toByteArray()
                        val md = java.security.MessageDigest.getInstance("SHA1")
                        val digest = md.digest(sigBytes)
                        digest.joinToString(":") { "%02X".format(it) }
                    } else {
                        @Suppress("DEPRECATION")
                        val info = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
                        val sigBytes = info.signatures[0].toByteArray()
                        val md = java.security.MessageDigest.getInstance("SHA1")
                        val digest = md.digest(sigBytes)
                        digest.joinToString(":") { "%02X".format(it) }
                    }
                    result.success(sig)
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
