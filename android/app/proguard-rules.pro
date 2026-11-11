# Flutter / AndroidX / WorkManager / Room ProGuard Keep Rules

# Keep WorkManager implementation and database components
-keep class * extends androidx.room.RoomDatabase {
    <init>();
}
-keep class androidx.work.impl.WorkDatabase* { *; }
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker { *; }

# Google Mobile Ads / Play Services Keep Rules
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-keep class androidx.startup.** { *; }

# Suppress harmless warnings for missing optional classes
-dontwarn androidx.work.**
-dontwarn androidx.room.**
-dontwarn com.google.android.gms.ads.**
