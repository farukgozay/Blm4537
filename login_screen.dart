import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import 'dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  void _login() async {
    final api = ref.read(apiServiceProvider);
    final token = await api.login(_userController.text, _passController.text);
    
    if (token != null) {
      api.setToken(token); // Token'ı kaydet
      if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Giriş Başarısız! Swagger'dan kayıt oldun mu?")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hoşgeldiniz,", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const Text("Analize başlamak için giriş yapın.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            TextField(controller: _userController, decoration: const InputDecoration(labelText: "Kullanıcı Adı", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: "Şifre", border: OutlineInputBorder())),
            const SizedBox(height: 30),
            SizedBox(width: double.infinity, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007BFF), padding: const EdgeInsets.all(15)),
              onPressed: _login, child: const Text("GİRİŞ YAP", style: TextStyle(color: Colors.white)),
            )),
          ],
        ),
      ),
    );
  }
}