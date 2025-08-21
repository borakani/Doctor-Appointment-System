class Doctor {
  String adSoyad;
  String bolum;
  List<String> gunler;
  List<String> saatler;

  Doctor({
    required this.adSoyad,
    required this.bolum,
    required this.gunler,
    required this.saatler,
  });

  factory Doctor.fromJson(Map<dynamic, dynamic> json) {
    return Doctor(
      adSoyad: json['adSoyad'] ?? '',
      bolum: json['bolum'] ?? '',
      gunler: List<String>.from(json['gunler'] ?? []),
      saatler: List<String>.from(json['saatler'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adSoyad': adSoyad,
      'bolum': bolum,
      'gunler': gunler,
      'saatler': saatler,
    };
  }
}
