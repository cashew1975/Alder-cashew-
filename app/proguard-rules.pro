# Release builds drop debug, verbose and info logging: those lines can carry addon urls, and addon urls carry
# debrid keys. Warnings stay, written so they never include a url (see the Log.w calls).
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
}
