import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';

class AddPlayerScreen extends ConsumerStatefulWidget {
  const AddPlayerScreen({super.key});
  @override
  ConsumerState<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends ConsumerState<AddPlayerScreen> {
  final nameCtrl = TextEditingController();
  final teamCtrl = TextEditingController();
  final posCtrl = TextEditingController();
  final imgCtrl = TextEditingController();
  File? selectedFile;

  // Dosya Seçici
  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, 
      allowedExtensions: ['csv']
    );
    
    if (result != null) {
      setState(() => selectedFile = File(result.files.single.path!));
    }
  }

  // Kaydet ve Yükle
  void _save() async {
    // 1. KONTROLLER (Validation)
    if (nameCtrl.text.isEmpty || teamCtrl.text.isEmpty || posCtrl.text.isEmpty || imgCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("❌ Lütfen oyuncunun tüm bilgilerini girin!"),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("❌ Şut verisi (CSV) yüklemeden oyuncu oluşturulamaz!"),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    // 2. İŞLEMİ BAŞLAT
    final api = ref.read(apiServiceProvider);
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⏳ Oyuncu ekleniyor...")));

      // A) Oyuncuyu Yarat
      final player = await api.addPlayer({
        "name": nameCtrl.text,
        "team": teamCtrl.text,
        "position": posCtrl.text,
        "imageUrl": imgCtrl.text,
      });

      if (player != null) {
        // B) Dosyayı Yükle
        bool uploadSuccess = await api.uploadShots(player.id, selectedFile!);
        
        if (uploadSuccess) {
          if(mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("✅ Oyuncu ve Veriler Eklendi!"), 
              backgroundColor: Colors.green
            ));
            Navigator.pop(context);
            ref.refresh(apiServiceProvider); // Ana listeyi yenile
          }
        } else {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ Oyuncu oluşturuldu ama dosya yüklenemedi.")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("❌ Hata: Oyuncu oluşturulamadı.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Oyuncu Ekle")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _input(nameCtrl, "Ad Soyad"),
            _input(teamCtrl, "Takım"),
            _input(posCtrl, "Pozisyon"),
            _input(imgCtrl, "Fotoğraf URL"),
            const SizedBox(height: 20),
            
            // Dosya Seçme Kutusu
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.all(30),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: selectedFile != null ? Colors.green : Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF1E1E1E),
                ),
                child: Column(
                  children: [
                    Icon(Icons.upload_file, size: 40, color: selectedFile != null ? Colors.green : const Color(0xFF007BFF)),
                    const SizedBox(height: 10),
                    Text(
                      selectedFile != null ? "Dosya Seçildi:\n${selectedFile!.path.split('\\').last}" : "CSV Dosyası Seç",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: selectedFile != null ? Colors.green : Colors.white)
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Kaydet Butonu
            SizedBox(width: double.infinity, child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D26A), 
                padding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              onPressed: _save, 
              child: const Text("KAYDET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
            ))
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl, 
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label, 
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: const Color(0xFF1E1E1E)
        )
      ),
    );
  }
}