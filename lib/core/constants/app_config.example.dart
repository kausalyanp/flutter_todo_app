class AppConfig {
  static const String firebaseDbUrl =
      'https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com';

  static const String firebaseApiKey = 'YOUR_FIREBASE_WEB_API_KEY';

  static String get signUpUrl =>
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$firebaseApiKey';

  static String get signInUrl =>
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$firebaseApiKey';

  static String get refreshTokenUrl =>
      'https://securetoken.googleapis.com/v1/token?key=$firebaseApiKey';

  static String tasksUrl(String userId, String? idToken) =>
      '$firebaseDbUrl/tasks/$userId.json?auth=$idToken';

  static String taskUrl(String userId, String taskId, String? idToken) =>
      '$firebaseDbUrl/tasks/$userId/$taskId.json?auth=$idToken';

  static String userStatusUrl(String userId, String? idToken) =>
      '$firebaseDbUrl/users/$userId.json?auth=$idToken';

  static const String appName = 'TodoFlow';
  static const int taskTitleMaxLength = 200;
}