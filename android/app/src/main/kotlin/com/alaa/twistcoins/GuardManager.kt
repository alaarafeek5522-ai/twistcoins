package com.alaa.twistcoins

import android.content.Context

object GuardManager {
    init {
        System.loadLibrary("guard")
    }

    external fun nativeCheck(ctx: Context): Boolean
    external fun nativeCheckRoot(ctx: Context): Boolean  
    external fun nativeGetKey(seed: Int): String

    fun runAllChecks(ctx: Context): GuardResult {
        return try {
            val passed = nativeCheck(ctx)
            GuardResult(passed = passed, reason = if (!passed) "security_violation" else "ok")
        } catch (e: Exception) {
            GuardResult(passed = false, reason = "load_error")
        }
    }
}

data class GuardResult(val passed: Boolean, val reason: String)
