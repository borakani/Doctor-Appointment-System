import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Doctor.dart';
import 'DoctorSelectionPage.dart';
import 'MyAppointmets.dart';


class Anasayfa extends StatelessWidget {
  final String uid;

  const Anasayfa({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    // Firebase Auth'dan giriş yapmış kullanıcı bilgisi
    final User? user = FirebaseAuth.instance.currentUser;

    // Eğer kullanıcı yoksa uyarı verip login sayfasına yönlendirebilirsin
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('Lütfen giriş yapınız.'),
        ),
      );
    }

    // UID al
    final String uid = user.uid;

    // Doktor listesi örneği (bunu istersen Firebase’den de çekebilirsin)
    final Map<String, List<Doctor>> doktorListesi = {
      "Dahiliye": [
        Doctor(
          adSoyad: "Dr. Ece Nur Özmen",
          bolum: "Dahiliye",
          gunler: ["Pazartesi", "Salı", "Perşembe"],
          saatler: saatListesi,
        ),
      ],
      "Kardiyoloji": [
        Doctor(
          adSoyad: "Dr. Fatih Asım Emektar",
          bolum: "Kardiyoloji",
          gunler: ["Pazartesi", "Salı", "Perşembe", "Cuma"],
          saatler: saatListesi,
        ),
      ],
      "Kadın Hastalıkları ve Doğum": [
        Doctor(
          adSoyad: "Dr. Gökçe Kani",
          bolum: "Kadın Hastalıkları ve Doğum",
          gunler: ["Pazartesi", "Salı", "Perşembe", "Cuma"],
          saatler: saatListesi,
        ),
      ],
      "Ortopedi": [
        Doctor(
          adSoyad: "Dr. Öykü Simay Ayaz",
          bolum: "Ortopedi",
          gunler: ["Pazartesi", "Salı", "Perşembe", "Cuma"],
          saatler: saatListesi,
        ),
      ],
      "Göz Hastalıkları": [
        Doctor(
          adSoyad: "Dr. Ekrem Bora Kani",
          bolum: "Göz Hastalıkları",
          gunler: ["Pazartesi", "Salı", "Perşembe", "Cuma"],
          saatler: saatListesi,
        ),
      ],
      "Cildiye": [
        Doctor(
          adSoyad: "Dr. Burak Emin Karadeniz",
          bolum: "Cildiye",
          gunler: ["Pazartesi", "Salı", "Perşembe", "Cuma"],
          saatler: saatListesi,
        ),
      ],
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ana Sayfa"),
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: Image.asset(
              'assets/images/meddata.webp',
              height: 300,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Randevu Al"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorSelectionPage(
                      doktorlar: doktorListesi,
                      uid: uid, // UID'yi gönderiyoruz
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.list),
            label: const Text("Randevularım"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyAppointments(uid: uid),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

const List<String> saatListesi = [
  "9.00", "9.20", "9.40", "10.00", "10.20", "10.40",
  "11.00", "11.20", "11.40", "12.00",
  "13.30", "13.50", "14.10", "14.30", "14.50", "15.10",
  "15.30", "15.50", "16.10", "16.30"
];
