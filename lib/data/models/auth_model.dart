class AuthModel {
  final String localId;
  final String email;
  final String idToken;
  final String refreshToken;
  final int expiresAt;

  const AuthModel({
    required this.localId,
    required this.email,
    required this.idToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  bool get isExpired =>
      DateTime.now().millisecondsSinceEpoch >= expiresAt;

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final expiresIn =
        int.tryParse(json['expiresIn']?.toString() ?? '3600') ?? 3600;
    return AuthModel(
      localId: json['localId'] as String,
      email: json['email'] as String,
      idToken: json['idToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.now()
          .add(Duration(seconds: expiresIn))
          .millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() => {
        'localId': localId,
        'email': email,
        'idToken': idToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt,
      };

  factory AuthModel.fromStoredJson(Map<String, dynamic> json) {
    return AuthModel(
      localId: json['localId'] as String,
      email: json['email'] as String,
      idToken: json['idToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: json['expiresAt'] as int,
    );
  }

  AuthModel copyWith({String? idToken, int? expiresAt}) {
    return AuthModel(
      localId: localId,
      email: email,
      idToken: idToken ?? this.idToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}