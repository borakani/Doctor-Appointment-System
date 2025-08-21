import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hastane_randevu/LoginPage.dart';
import 'Doctor.dart';

// Doktor verileri
final Map<String, List<Doctor>> bolumVeDoktorlar = {
  "Dahiliye": [
    Doctor(
        adSoyad: "Dr. Ece Nur Özmen",
        bolum: "Dahiliye",
        gunler: ["Pazartesi", "Salı", "Perşembe"],
        saatler: [
          "9.00",
          "9.20",
          "9.40",
          "10.00",
          "10.20",
          "10.40",
          "11.00",
          "11.20",
          "11.40",
          "12.00",
          "13.30",
          "13.50",
          "14.10",
          "14.30",
          "14.50",
          "15.10",
          "15.30",
          "15.50",
          "16.10",
          "16.30",
        ]),
  ],
  "Kardiyoloji": [
    Doctor(
        adSoyad: "Dr. Fatih Asım Emektar",
        bolum: "Kardiyoloji",
        gunler: ["Pazartesi", "Salı", "Perşembe", "Cuma"],
        saatler: [
          "9.00",
          "9.20",
          "9.40",
          "10.00",
          "10.20",
          "10.40",
          "11.00",
          "11.20",
          "11.40",
          "12.00",
          "13.30",
          "13.50",
          "14.10",
          "14.30",
          "14.50",
          "15.10",
          "15.30",
          "15.50",
          "16.10",
          "16.30",
        ]),
  ],
  "Kadın Hastalıkları ve Doğum": [
    Doctor(
        adSoyad: "Dr. Gökçe Kani",
        bolum: "Kadın Hastalıkları ve Doğum",
        gunler: ["Pazartesi", "Salı", "Perşembe", "Cuma"],
        saatler: [
          "9.00",
          "9.20",
          "9.40",
          "10.00",
          "10.20",
          "10.40",
          "11.00",
          "11.20",
          "11.40",
          "12.00",
          "13.30",
          "13.50",
          "14.10",
          "14.30",
          "14.50",
          "15.10",
          "15.30",
          "15.50",
          "16.10",
          "16.30",
        ]),
  ],
  "Ortopedi": [
    Doctor(
        adSoyad: "Dr. Öykü Simay Ayaz",
        bolum: "Ortopedi",
        gunler: ["Pazartesi", "Salı", "Perşembe", "Cuma"],
        saatler: [
          "9.00",
          "9.20",
          "9.40",
          "10.00",
          "10.20",
          "10.40",
          "11.00",
          "11.20",
          "11.40",
          "12.00",
          "13.30",
          "13.50",
          "14.10",
          "14.30",
          "14.50",
          "15.10",
          "15.30",
          "15.50",
          "16.10",
          "16.30",
        ]),
  ],
  "Göz Hastalıklar": [
    Doctor(
        adSoyad: "Dr. Ekrem Bora Kani",
        bolum: "Göz Hastalıklar",
        gunler: ["Pazartesi", "Salı", "Perşembe", "Cuma"],
        saatler: [
          "9.00",
          "9.20",
          "9.40",
          "10.00",
          "10.20",
          "10.40",
          "11.00",
          "11.20",
          "11.40",
          "12.00",
          "13.30",
          "13.50",
          "14.10",
          "14.30",
          "14.50",
          "15.10",
          "15.30",
          "15.50",
          "16.10",
          "16.30",
        ]),
  ],
  "Cildiye": [
    Doctor(
        adSoyad: "Dr. Burak Emin Karadeniz",
        bolum: "Cildiye",
        gunler: ["Pazartesi", "Salı", "Perşembe", "Cuma"],
        saatler: [
          "9.00",
          "9.20",
          "9.40",
          "10.00",
          "10.20",
          "10.40",
          "11.00",
          "11.20",
          "11.40",
          "12.00",
          "13.30",
          "13.50",
          "14.10",
          "14.30",
          "14.50",
          "15.10",
          "15.30",
          "15.50",
          "16.10",
          "16.30",
        ]),
  ],
};

class BeginningPage extends StatefulWidget {
  const BeginningPage({Key? key}) : super(key: key);

  @override
  State<BeginningPage> createState() => _BeginningpageState();
}

class _BeginningpageState extends State<BeginningPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _doktorlariFirebaseEkle().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _doktorlariFirebaseEkle() async {
    final db = FirebaseDatabase.instance.ref();

    // Öncelikle kontrol etmek istersen, sadece boşsa ekleme yapabilirsin.
    final snapshot = await db.child("Bolumler").get();
    if (snapshot.exists) {
      // Veri zaten varsa tekrar ekleme yapma
      print("Veri zaten var, ekleme yapılmadı.");
      return;
    }

    for (var bolum in bolumVeDoktorlar.keys) {
      for (var doktor in bolumVeDoktorlar[bolum]!) {
        await db.child("Bolumler/$bolum/doktorlar").push().set(doktor.toJson());
        print("${doktor.adSoyad} Firebase'e eklendi.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      // Veri yüklendikten sonra login sayfasına yönlendir
      return const LoginPage();
    }
  }
}
