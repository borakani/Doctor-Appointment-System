import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MyAppointments extends StatefulWidget {
  final String uid;

  const MyAppointments({super.key, required this.uid});

  @override
  State<MyAppointments> createState() => _MyAppointmentsState();
}

class _MyAppointmentsState extends State<MyAppointments> {
  Map<String, Map<String, dynamic>> randevularMap = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _randevulariGetir();
  }

  Future<void> _randevulariGetir() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final randevularRef = FirebaseDatabase.instance.ref("Kullanicilar/${user.uid}/randevular");
    final snapshot = await randevularRef.get();

    if (!snapshot.exists || snapshot.value == null) {
      setState(() {
        randevularMap = {};
        loading = false;
      });
      return;
    }

    if (snapshot.value is Map) {
      final dataMap = Map<String, dynamic>.from(snapshot.value as Map);

      // Map<String, Map<String, dynamic>> yapısına çeviriyoruz
      Map<String, Map<String, dynamic>> tempMap = {};
      dataMap.forEach((key, value) {
        if (value is Map) {
          tempMap[key] = Map<String, dynamic>.from(value);
        }
      });

      setState(() {
        randevularMap = tempMap;
        loading = false;
      });
    } else {
      setState(() {
        randevularMap = {};
        loading = false;
      });
    }
  }

  Future<void> _randevuSil(String key, Map<String, dynamic> randevu) async {
    final uid = widget.uid;
    final bolum = randevu['bolum'] ?? '';
    final doktor = randevu['doktor'] ?? '';
    final tarih = randevu['tarih'] ?? '';
    final saat = randevu['saat'] ?? '';

    String temizleFirebasePath(String s) {
      return s
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll('.', '')
          .replaceAll('ç', 'c')
          .replaceAll('ş', 's')
          .replaceAll('ğ', 'g')
          .replaceAll('ü', 'u')
          .replaceAll('ö', 'o')
          .replaceAll('ı', 'i');
    }

    final temizBolum = temizleFirebasePath(bolum);
    final temizDoktor = temizleFirebasePath(doktor);

    try {
      // Kullanıcı altından sil
      final kullaniciRef = FirebaseDatabase.instance.ref("Kullanicilar/$uid/randevular/$key");
      await kullaniciRef.remove();

      // Genel randevu listesinden sil
      final genelRef = FirebaseDatabase.instance.ref("Randevular/$temizBolum/$temizDoktor/$tarih/$saat");
      await genelRef.remove();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Randevu silindi.")),
      );

      // Listeyi güncelle
      await _randevulariGetir();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Randevu silinemedi: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Randevularım")),
        body: const Center(child: Text("Giriş yapılmamış.")),
      );
    }

    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Randevularım")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (randevularMap.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Randevularım")),
        body: const Center(child: Text("Randevunuz yok.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Randevularım")),
      body: ListView(
        children: randevularMap.entries.map((entry) {
          final key = entry.key;
          final randevu = entry.value;
          final bolum = randevu['bolum'] ?? "Bölüm bilinmiyor";
          final doktor = randevu['doktor'] ?? "Doktor bilinmiyor";
          final tarih = randevu['tarih'] ?? "-";
          final saat = randevu['saat'] ?? "-";

          return ListTile(
            title: Text("$bolum - $doktor"),
            subtitle: Text("$tarih $saat"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final sonuc = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Randevu Sil"),
                    content: const Text("Randevuyu silmek istediğinize emin misiniz?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("İptal"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("Sil"),
                      ),
                    ],
                  ),
                );

                if (sonuc == true) {
                  await _randevuSil(key, randevu);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
