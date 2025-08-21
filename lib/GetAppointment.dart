import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'Doctor.dart';

class GetAppointment extends StatefulWidget {
  final Doctor doktor;
  final String uid;

  const GetAppointment({super.key, required this.doktor, required this.uid});

  @override
  State<GetAppointment> createState() => _GetAppointmentState();
}

class _GetAppointmentState extends State<GetAppointment> {
  String? secilenSaat;
  final List<String> saatler = [
    "09:00",
    "09:30",
    "10:00",
    "10:30",
    "11:00",
    "11:30",
    "13:00",
    "13:30",
    "14:00",
    "14:30",
    "15:00",
  ];

  DateTime? secilenTarih;
  List<String> doluSaatler = [];

  // Firebase path için temizleme fonksiyonu
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

  Future<void> doluSaatleriGetir(String tarih) async {
    final bolumTemiz = temizleFirebasePath(widget.doktor.bolum);
    final doktorTemiz = temizleFirebasePath(widget.doktor.adSoyad);

    final ref = FirebaseDatabase.instance.ref("Randevular/$bolumTemiz/$doktorTemiz/$tarih");
    final snapshot = await ref.get();

    if (snapshot.exists && snapshot.value is Map) {
      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      doluSaatler = data.keys.map((key) => key.toString().trim()).toList();
    } else {
      doluSaatler = [];
    }
    print("Dolu saatler: $doluSaatler");
    setState(() {}); // UI güncelle
  }

  Future<void> randevuKaydet({
    required BuildContext context,
    required String tarih,
    required String saat,
    required String gun,
  }) async {
    final uid = widget.uid;
    final doktorAdi = widget.doktor.adSoyad;
    final bolum = widget.doktor.bolum;

    final temizBolum = temizleFirebasePath(bolum);
    final temizDoktorAdi = temizleFirebasePath(doktorAdi);

    try {
      final kullaniciRef = FirebaseDatabase.instance.ref("Kullanicilar/$uid/randevular/${tarih}_$saat");

      final randevuVerisi = {
        'doktor': doktorAdi,
        'bolum': bolum,
        'saat': saat,
        'gun': gun,
        'tarih': tarih,
      };

      await kullaniciRef.set(randevuVerisi);

      final genelRandevuRef = FirebaseDatabase.instance.ref("Randevular/$temizBolum/$temizDoktorAdi/$tarih/$saat");

      final genelRandevuVerisi = {
        'uid': uid,
        'doktor': doktorAdi,
        'bolum': bolum,
        'tarih': tarih,
        'saat': saat,
        'gun': gun,
      };

      await genelRandevuRef.set(genelRandevuVerisi);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Randevu başarıyla kaydedildi.")),
      );

      // Randevu alındıktan sonra dolu saatleri güncelle
      await doluSaatleriGetir(tarih);
      setState(() {
        secilenSaat = null; // Seçilen saati sıfırla
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Randevu kaydedilemedi: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Randevu Al")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Bölüm: ${widget.doktor.bolum}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Doktor: ${widget.doktor.adSoyad}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () async {
                final secilen = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (secilen != null) {
                  setState(() {
                    secilenTarih = secilen;
                    secilenSaat = null; // Tarih değişince saati sıfırla
                  });

                  final tarihStr = "${secilen.year}-${secilen.month.toString().padLeft(2, '0')}-${secilen.day.toString().padLeft(2, '0')}";
                  await doluSaatleriGetir(tarihStr);
                }
              },
              child: const Text("Tarih Seç"),
            ),
            const SizedBox(height: 8),
            if (secilenTarih != null)
              Text("Seçilen Tarih: ${secilenTarih!.toLocal().toString().split(" ")[0]}"),
            const SizedBox(height: 16),

            const Text("Saat Seçin:", style: TextStyle(fontSize: 16)),
            Wrap(
              spacing: 8,
              children: saatler.map((saat) {
                final dolu = doluSaatler.any((ds) => ds.trim() == saat.trim());

                return ChoiceChip(
                  label: Text(saat),
                  selected: secilenSaat == saat,
                  onSelected: dolu
                      ? null
                      : (selected) {
                    setState(() {
                      secilenSaat = saat;
                    });
                  },
                  disabledColor: Colors.grey.shade400,
                );
              }).toList(),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () async {
                if (secilenTarih == null || secilenSaat == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lütfen tarih ve saat seçin.")),
                  );
                  return;
                }

                final tarihStr = "${secilenTarih!.year}-${secilenTarih!.month.toString().padLeft(2, '0')}-${secilenTarih!.day.toString().padLeft(2, '0')}";
                final gun = _getGunAdi(secilenTarih!);

                if (doluSaatler.any((ds) => ds.trim() == secilenSaat!.trim())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Seçilen saat dolu, lütfen başka saat seçin.")),
                  );
                  return;
                }

                await randevuKaydet(
                  context: context,
                  tarih: tarihStr,
                  saat: secilenSaat!,
                  gun: gun,
                );
              },
              child: const Text("Randevu Al"),
            ),
          ],
        ),
      ),
    );
  }

  String _getGunAdi(DateTime tarih) {
    const gunler = ["Pazartesi", "Sali", "Carsamba", "Persembe", "Cuma", "Cumartesi", "Pazar"];
    return gunler[tarih.weekday - 1];
  }
}
