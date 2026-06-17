# Fix for PDFBox JPX issue
-dontwarn com.gemalto.jp2.**
-keep class com.gemalto.jp2.** { *; }

# Keep PDFBox classes
-keep class com.tom_roush.pdfbox.** { *; }
-dontwarn com.tom_roush.pdfbox.**

# File picker safety
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-dontwarn com.mr.flutter.plugin.filepicker.**

# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.gemalto.jp2.JP2Decoder