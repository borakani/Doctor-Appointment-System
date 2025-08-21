import 'package:flutter/material.dart';
import 'Doctor.dart';
import 'GetAppointment.dart';

class DoctorSelectionPage extends StatefulWidget {
  final Map<String, List<Doctor>> doktorlar;
  final String uid;

  const DoctorSelectionPage({super.key, required this.doktorlar, required this.uid});

  @override
  State<DoctorSelectionPage> createState() => _DoctorSelectionPageState();
}

class _DoctorSelectionPageState extends State<DoctorSelectionPage> {
  String? secilenBolum;
  List<Doctor> doktorlarListesi = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doktor Seçimi"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: const Text("Bölüm Seçiniz"),
              value: secilenBolum,
              items: widget.doktorlar.keys.map((bolum) {
                return DropdownMenuItem(
                  value: bolum,
                  child: Text(bolum),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  secilenBolum = value;
                  doktorlarListesi = widget.doktorlar[value] ?? [];
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: doktorlarListesi.isEmpty
                  ? const Center(child: Text("Lütfen bir bölüm seçiniz"))
                  : ListView.builder(
                itemCount: doktorlarListesi.length,
                itemBuilder: (context, index) {
                  final doktor = doktorlarListesi[index];
                  return ListTile(
                    title: Text(doktor.adSoyad),
                    subtitle: Text("Randevu Saatleri: ${doktor.saatler.join(', ')}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GetAppointment(
                            doktor: doktor,
                            uid: widget.uid, // UID'yi de gönderiyoruz
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
