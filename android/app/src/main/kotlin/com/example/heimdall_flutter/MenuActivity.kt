package com.example.heimdall_flutter

import android.app.Activity
import android.os.Bundle
import android.widget.TextView
import android.widget.Button

class MenuActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Load layout by name to avoid direct R references
        val layoutId = resources.getIdentifier("activity_menu", "layout", packageName)
        if (layoutId != 0) setContentView(layoutId)

        // Simple example: set a title or text from intent extras
        val titleId = resources.getIdentifier("menu_title", "id", packageName)
        val titleView: TextView? = if (titleId != 0) findViewById(titleId) else null
        val title = intent?.getStringExtra("title") ?: "Menú"
        titleView?.text = title

        // Wire the native button to close this native activity and return to Flutter
        val backBtnId = resources.getIdentifier("button_open_flutter", "id", packageName)
        val backBtn: Button? = if (backBtnId != 0) findViewById(backBtnId) else null
        backBtn?.setOnClickListener {
            finish()
        }
    }
}
