class UserProfileData {
  final String username;
  final String email;
  final Map<String, double> percentualiGeneri;

  UserProfileData({
    required this.username,
    required this.email,
    required this.percentualiGeneri,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    var generiJson = json['percentualiGeneri'] as Map<String, dynamic>? ?? {};
    Map<String, double> castedGeneri = {};
    generiJson.forEach((key, value) {
      castedGeneri[key] = (value as num).toDouble();
    });

    return UserProfileData(
      username: json['username'] ?? 'Utente Kindle',
      email: json['email'] ?? 'julia.zambonelli@studenti.unibg.it',
      percentualiGeneri: castedGeneri,
    );
  }
}