package com.alaa.twistcoins

import android.os.Bundle
import android.os.Process
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        val result = GuardManager.runAllChecks(this)
        if (!result.passed) {
            Process.killProcess(Process.myPid())
            return
        }
        super.onCreate(savedInstanceState)
    }
}
