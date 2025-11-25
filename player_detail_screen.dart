import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';

final playerDetailProvider = FutureProvider.family((ref, int id) => ref.read(apiServiceProvider).getPlayerDetails(id));

class PlayerDetailScreen extends ConsumerWidget {
  final int playerId;
  const PlayerDetailScreen({super.key, required this.playerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(playerDetailProvider(playerId));

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text("Oyuncu Analizi")),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Veri Yok: $e")),
        data: (data) {
          if (data == null) return const Center(child: Text("Veri bulunamadı"));
          
          final player = data['player'];
          final stats = data['stats'];
          final shots = data['shots'] as List;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ÜST BİLGİ (Profil)
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF007BFF), width: 3)),
                        child: CircleAvatar(radius: 50, backgroundImage: NetworkImage(player['imageUrl'])),
                      ),
                      const SizedBox(height: 10),
                      Text(player['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text("${player['team']} | ${player['position']}", style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // 2. İSTATİSTİK KUTULARI (Grid)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _statCard("eFG%", "${stats['efgPercent']}%", const Color(0xFF00D26A)), // Yeşil
                    _statCard("TS%", "${stats['tsPercent']}%", const Color(0xFF007BFF)), // Mavi
                    _statCard("FG%", "${stats['fgPercent']}%", Colors.orange),
                    _statCard("Toplam Şut", "${stats['totalShots']}", Colors.purpleAccent),
                  ],
                ),
                const SizedBox(height: 30),

                // 3. ŞUT HARİTASI (PREMIUM)
                const Text("Şut Haritası", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 15),
                
                Center(
                  child: Container(
                    // Sahanın gerçek oranlarını korumak için ConstrainedBox
                    constraints: const BoxConstraints(maxWidth: 500), 
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double width = constraints.maxWidth;
                        // NBA sahası oranı (50ft genişlik / 47ft yarısaha uzunluğu = 0.94)
                        double height = width * 0.94; 

                        return Container(
                          width: width,
                          height: height,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD2A679), // Resim yüklenmezse diye parke rengi
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24, width: 2),
                            image: const DecorationImage(
                              // ARTIK ASSET KULLANIYORUZ - İNTERNETE GEREK YOK
                              image: AssetImage('assets/court.png'), 
                              fit: BoxFit.fill,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 5))
                            ]
                          ),
                          child: Stack(
                            children: shots.map<Widget>((shot) {
                              // KOORDİNAT HESABI
                              // X: -25..25 -> 0..Width
                              double left = ((shot['x'] + 25) / 50) * width;
                              
                              // Y: 0..47 -> Height..0 (Flutter'da 0 en üsttür)
                              // Pota altı (0) görselin altında olsun istiyoruz.
                              // 47'ye bölüp görselin %90'ına sığdırıyoruz ki çizgilerle otursun
                              double bottom = (shot['y'] / 47) * (height * 0.9); 

                              bool made = shot['made'];
                              Color dotColor = made ? const Color(0xFF00FF00) : const Color(0xFFFF0000);

                              return Positioned(
                                left: left - 6, // Nokta merkezleme (12px / 2)
                                bottom: bottom, 
                                child: Container(
                                  width: 12, height: 12,
                                  decoration: BoxDecoration(
                                    color: dotColor.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withOpacity(0.8), width: 1), // Beyaz kontür
                                    boxShadow: [
                                      BoxShadow(color: dotColor.withOpacity(0.6), blurRadius: 8, spreadRadius: 2) // Neon Efekt
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Legend (Harita Açıklaması)
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendItem(const Color(0xFF00FF00), "İsabet"),
                      const SizedBox(width: 25),
                      _legendItem(const Color(0xFFFF0000), "Kaçan"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 6)])),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
      ],
    );
  }
}