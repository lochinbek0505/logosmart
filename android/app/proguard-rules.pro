-dontwarn java.beans.**
-dontwarn org.yaml.snakeyaml.**
-keep class org.yaml.snakeyaml.** { *; }


# TensorFlow Lite kutubxonalarini o'zgartirmaslik va o'chirmaslik uchun
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# Agar sizda tflite_flutter paketidan foydalanilayotgan bo'lsa:
-keep class tflite.** { *; }
-dontwarn tflite.**


# flutter_local_notifications (release build'da bildirishnoma ko'rinishi uchun)
-keep class com.dexterous.** { *; }
-keep class com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.reflect.TypeToken
-keepattributes Signature
-keepattributes *Annotation*

# Firebase Messaging
-keep class com.google.firebase.messaging.** { *; }
-dontwarn com.google.firebase.messaging.**
