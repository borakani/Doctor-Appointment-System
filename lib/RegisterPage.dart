import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController sifreController = TextEditingController();
  final TextEditingController tcController = TextEditingController();
  final TextEditingController adSoyadController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  void kayitOl() async {
    final email = emailController.text.trim();
    final sifre = sifreController.text.trim();
    final tc = tcController.text.trim();
    final adSoyad = adSoyadController.text.trim();

    if (email.isEmpty || sifre.length < 6 || tc.length != 11 || adSoyad.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doğru doldurun (Şifre en az 6 karakter).")),
      );
      return;
    }

    try {
      // Email+şifre ile kayıt
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: sifre);

      final uid = userCredential.user!.uid;

      // Kullanıcı bilgilerini Realtime DB'ye yaz
      await _dbRef.child("Kullanicilar").child(uid).set({
        "tc": tc,
        "ad_soyad": adSoyad,
        "email": email,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kayıt başarılı! Giriş yapabilirsiniz.")),
      );

      Navigator.pop(context); // Kayıt sonrası geri dön
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: ${e.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kayıt Ol")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: adSoyadController,
              decoration: const InputDecoration(labelText: "Ad Soyad"),
            ),
            TextField(
              controller: tcController,
              keyboardType: TextInputType.number,
              maxLength: 11,
              decoration: const InputDecoration(labelText: "TC Kimlik Numarası"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: sifreController,
              decoration: const InputDecoration(labelText: "Şifre"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: kayitOl,
              child: const Text("Kayıt Ol"),
            ),
          ],
        ),
      ),
    );
  }
}
