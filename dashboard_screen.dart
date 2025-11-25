import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import 'add_player_screen.dart';
import 'compare_screen.dart';

final playersProvider = FutureProvider((ref) => ref.read(apiServiceProvider).getPlayers());

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(playersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Oyuncu Panosu"),
        actions: [
          IconButton(onPressed: () => ref.refresh(playersProvider), icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Stack(
        children: [
          playersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text("Hata: $e")),
            data: (players) => ListView.builder(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final p = players[index];
                // PlayerCard'a silme fonksiyonu gönderiyoruz
                return PlayerCard(
                  player: p, 
                  onDelete: () async {
                    // ONAY KUTUSU
                    bool? confirm = await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Oyuncuyu Sil"),
                        content: Text("${p.name} silinecek. Emin misin?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("İptal")),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("SİL", style: TextStyle(color: Colors.red))),
                        ],
                      )
                    );

                    if (confirm == true) {
                      await ref.read(apiServiceProvider).deletePlayer(p.id);
                      ref.refresh(playersProvider); // Listeyi yenile
                    }
                  },
                ); 
              },
            ),
          ),

          Positioned(
            bottom: 30, left: 20, right: 20,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _actionButton(context, "Yeni Oyuncu", Icons.add, const Color(0xFF007BFF), const AddPlayerScreen()),
                        Container(height: 20, width: 1, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 15)),
                        _actionButton(context, "Kıyasla", Icons.compare_arrows, const Color(0xFFE91E63), const CompareScreen()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, String label, IconData icon, Color color, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}