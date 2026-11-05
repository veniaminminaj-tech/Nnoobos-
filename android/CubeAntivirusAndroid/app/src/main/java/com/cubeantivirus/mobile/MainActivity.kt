package com.cubeantivirus.mobile

import android.app.Activity
import android.os.Bundle
import android.content.Intent
import android.graphics.Color
import android.view.Gravity
import android.widget.*
import androidx.documentfile.provider.DocumentFile
import java.security.MessageDigest
import java.util.concurrent.Executors

class MainActivity : Activity() {
    private lateinit var output: TextView
    private lateinit var status: TextView
    private val executor = Executors.newSingleThreadExecutor()
    private val prefs by lazy { getSharedPreferences("cube_mobile", MODE_PRIVATE) }
    private var scanned = 0
    private var warnings = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.statusBarColor = Color.rgb(12, 18, 32)
        window.navigationBarColor = Color.rgb(12, 18, 32)
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(22, 26, 22, 18)
            setBackgroundColor(Color.rgb(12, 18, 32))
        }
        fun text(value: String, size: Float, color: Int = Color.WHITE) = TextView(this).apply {
            this.text = value; textSize = size; setTextColor(color)
        }
        root.addView(text("CUBE ANTIVIRUS", 26f, Color.rgb(75, 190, 255)))
        root.addView(text("Mobile Security • Android", 14f, Color.LTGRAY))
        status = text("Стан: готовий до перевірки", 16f)
        status.setPadding(0, 24, 0, 16)
        root.addView(status)
        val scan = Button(this).apply {
            text = "ВИБРАТИ ПАПКУ ДЛЯ СКАНУВАННЯ"
            setOnClickListener {
                val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
                startActivityForResult(intent, 41)
            }
        }
        root.addView(scan)
        val history = Button(this).apply {
            text = "ІСТОРІЯ ПЕРЕВІРОК"
            setOnClickListener { output.text = prefs.getString("history", "Історія поки порожня") }
        }
        root.addView(history)
        output = text("Вибери папку, до якої хочеш надати доступ.\n\nСканер працює лише з вибраними файлами та не видаляє їх.", 14f, Color.rgb(210, 220, 235))
        output.setPadding(0, 20, 0, 0)
        val scroll = ScrollView(this).apply { addView(output) }
        root.addView(scroll, LinearLayout.LayoutParams(-1, 0, 1f))
        root.addView(text("Cube Antivirus не замінює Google Play Protect.", 12f, Color.GRAY))
        setContentView(root)
    }

    @Deprecated("Legacy activity result API for broad device compatibility")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != 41 || resultCode != RESULT_OK) return
        val uri = data?.data ?: return
        contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
        val tree = DocumentFile.fromTreeUri(this, uri) ?: return
        status.text = "Стан: сканування…"
        output.text = "Перевірка почалася. Файли не змінюються."
        executor.execute {
            scanned = 0; warnings = 0
            val findings = mutableListOf<String>()
            scanTree(tree, findings, 0)
            val report = "Перевірено: $scanned файлів\nПопереджень: $warnings\n\n" +
                if (findings.isEmpty()) "Підозрілих текстових ознак не знайдено." else findings.joinToString("\n\n")
            val old = prefs.getString("history", "") ?: ""
            prefs.edit().putString("history", "$report\n──────────\n$old".take(12000)).apply()
            runOnUiThread {
                status.text = "Стан: завершено • $scanned файлів • $warnings попереджень"
                output.text = report
            }
        }
    }

    private fun scanTree(dir: DocumentFile, findings: MutableList<String>, depth: Int) {
        if (depth > 20) return
        for (file in dir.listFiles()) {
            if (file.isDirectory) { scanTree(file, findings, depth + 1); continue }
            if (!file.isFile) continue
            scanned++
            try {
                val digest = MessageDigest.getInstance("SHA-256")
                val sample = ByteArrayOutputStreamCompat()
                contentResolver.openInputStream(file.uri)?.use { input ->
                    val buffer = ByteArray(8192); var total = 0
                    while (true) {
                        val n = input.read(buffer); if (n <= 0) break
                        digest.update(buffer, 0, n)
                        if (total < 65536) sample.write(buffer, 0, minOf(n, 65536 - total))
                        total += n
                    }
                }
                val hash = digest.digest().joinToString("") { "%02x".format(it) }
                val name = file.name ?: "(без назви)"
                val ext = name.substringAfterLast('.', "").lowercase()
                val content = sample.toStringUtf8().lowercase()
                val indicators = listOf("powershell -enc", "frombase64string", "wscript.shell", "invoke-expression", "downloadstring")
                val hits = indicators.filter { content.contains(it) }
                if (hits.isNotEmpty()) {
                    warnings++
                    findings.add("⚠ $name\nОзнаки для ручної перевірки: ${hits.joinToString(", ")}\nSHA-256: $hash")
                }
            } catch (_: Exception) { }
        }
    }

    override fun onDestroy() { executor.shutdownNow(); super.onDestroy() }

    private class ByteArrayOutputStreamCompat {
        private val out = java.io.ByteArrayOutputStream()
        fun write(b: ByteArray, off: Int, len: Int) = out.write(b, off, len)
        fun toStringUtf8() = out.toString(Charsets.UTF_8.name())
    }
}
