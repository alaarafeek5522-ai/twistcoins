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
                    val sigBytes = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        val info = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES)
                        info.signingInfo?.apkContentsSigners?.firstOrNull()?.toByteArray()
                    } else {
                        @Suppress("DEPRECATION")
                        val info = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
                        info.signatures?.firstOrNull()?.toByteArray()
                    }
                    if (sigBytes != null) {
                        val md = java.security.MessageDigest.getInstance("SHA1")
                        val digest = md.digest(sigBytes)
                        result.success(digest.joinToString(":") { "%02X".format(it) })
                    } else {
                        result.error("ERROR", "No signature found", null)
                    }
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
