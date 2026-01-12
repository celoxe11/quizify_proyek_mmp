/// Utility class to map technical error messages to user-friendly Indonesian messages
class ErrorMapper {
  /// Converts technical error messages to user-friendly messages in Indonesian
  static String getUserFriendlyMessage(String technicalError) {
    // Remove "Exception: " prefix if present
    String cleaned = technicalError.replaceFirst(RegExp(r'^Exception:\s*'), '');

    // Remove "ApiException: " prefix if present
    cleaned = cleaned.replaceFirst(RegExp(r'^ApiException:\s*'), '');

    // Map common error patterns to friendly messages
    final errorMappings = <RegExp, String>{
      // Duplicate errors
      RegExp(
        r'duplicate.*username|username.*duplicate|username sudah',
        caseSensitive: false,
      ): 'Username sudah digunakan. Silakan pilih username lain.',

      RegExp(
        r'duplicate.*email|email.*duplicate|email sudah',
        caseSensitive: false,
      ): 'Email sudah terdaftar. Silakan login atau gunakan email lain.',

      RegExp(r'Firebase.*duplicate|firebase.*sudah', caseSensitive: false):
          'Akun sudah terdaftar. Silakan login.',

      RegExp(
        r'PRIMARY.*sudah|duplicate.*primary|primary.*duplicate',
        caseSensitive: false,
      ): 'Terjadi kesalahan saat membuat akun. Silakan coba lagi.',

      // Connection errors
      RegExp(
        r'timeout|time.*out',
        caseSensitive: false,
      ): 'Koneksi timeout. Periksa internet Anda dan pastikan server berjalan.',

      RegExp(
        r'connection.*refused|unable to connect|failed to connect',
        caseSensitive: false,
      ): 'Tidak dapat terhubung ke server. Pastikan server berjalan.',

      RegExp(r'network.*error|no.*connection', caseSensitive: false):
          'Koneksi bermasalah. Periksa internet Anda.',

      // Server errors
      RegExp(r'internal server error|error 500', caseSensitive: false):
          'Terjadi kesalahan server. Silakan coba lagi.',

      RegExp(r'not.*found|error 404', caseSensitive: false):
          'Data tidak ditemukan.',

      // Authentication errors
      RegExp(r'unauthorized|error 401', caseSensitive: false):
          'Sesi Anda telah berakhir. Silakan login kembali.',

      RegExp(r'forbidden|error 403', caseSensitive: false):
          'Anda tidak memiliki akses ke fitur ini.',

      RegExp(
        r'invalid.*credentials|wrong.*password|incorrect.*password',
        caseSensitive: false,
      ): 'Email atau password salah.',

      // Firebase specific errors
      RegExp(r'email.*already.*in.*use', caseSensitive: false):
          'Email sudah digunakan. Silakan login atau gunakan email lain.',

      RegExp(r'weak.*password|password.*weak', caseSensitive: false):
          'Password terlalu lemah. Gunakan minimal 6 karakter.',

      RegExp(r'invalid.*email', caseSensitive: false):
          'Format email tidak valid.',

      // Account status
      RegExp(
        r'account.*inactive|inactive.*account|tidak aktif',
        caseSensitive: false,
      ): 'Akun Anda tidak aktif. Hubungi admin.',
    };

    // Check each pattern
    for (var entry in errorMappings.entries) {
      if (entry.key.hasMatch(cleaned)) {
        return entry.value;
      }
    }

    // Return cleaned message if no mapping found
    return cleaned;
  }

  /// Checks if an error is related to network connectivity
  static bool isNetworkError(String error) {
    final networkPatterns = [
      RegExp(r'timeout|time.*out', caseSensitive: false),
      RegExp(r'connection.*refused|unable to connect', caseSensitive: false),
      RegExp(r'network.*error|no.*connection', caseSensitive: false),
    ];

    return networkPatterns.any((pattern) => pattern.hasMatch(error));
  }

  /// Checks if an error is related to authentication
  static bool isAuthError(String error) {
    final authPatterns = [
      RegExp(r'unauthorized|error 401', caseSensitive: false),
      RegExp(r'invalid.*credentials', caseSensitive: false),
      RegExp(r'session.*expired', caseSensitive: false),
    ];

    return authPatterns.any((pattern) => pattern.hasMatch(error));
  }
}
