package uz.logosmart.logosmart

import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Resurslarni yuklashdan oldin bo'sh joyni tekshirish uchun
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "uz.logosmart/storage")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "freeBytes" -> result.success(StatFs(filesDir.absolutePath).availableBytes)
                    // Android'da zaxiradan chiqarish backup_rules / data_extraction_rules orqali
                    "excludeFromBackup" -> result.success(true)
                    else -> result.notImplemented()
                }
            }
    }
}
