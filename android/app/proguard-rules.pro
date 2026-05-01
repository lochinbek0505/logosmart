-dontwarn java.beans.**
-dontwarn org.yaml.snakeyaml.**
-keep class org.yaml.snakeyaml.** { *; }


# TensorFlow Lite kutubxonalarini o'zgartirmaslik va o'chirmaslik uchun
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# Agar sizda tflite_flutter paketidan foydalanilayotgan bo'lsa:
-keep class tflite.** { *; }
-dontwarn tflite.**

