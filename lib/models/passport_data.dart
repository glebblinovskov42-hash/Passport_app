class PassportData {
  final String text;
  final String? email;

  PassportData({
    required this.text,
    this.email,
  });

  PassportData copyWith({String? text, String? email}) {
    return PassportData(
      text: text ?? this.text,
      email: email ?? this.email,
    );
  }
}
