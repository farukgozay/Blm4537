import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../data/player_model.dart';

// Tüm oyuncuları getiren provider
final playersListProvider = FutureProvider((ref) => ref.read(apiServiceProvider).getPlayers());

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});
  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  Player? p1;
  Player? p2;
  Map<String, dynamic>? stats1;
  Map<String, dynamic>? stats2;

  // İstatistik Çeken Fonksiyon
  void _fetchStats(int pid, bool isP1) async {
    final data = await ref.read(apiServiceProvider).getPlayerDetails(pid);
    setState(() {
      if (isP1) stats1 = data?['stats'];
      else stats2 = data?['stats'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final playersAsync = ref.watch(playersListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Oyuncu Kıyasla")),
      body: playersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Hata: $e")),
        data: (players) => Column(
          children: [
            // 1. SEÇİM ALANI
            Container(
              padding: const EdgeInsets.all(16.0),
              color: const Color(0xFF1E1E1E),
              child: Row(
                children: [
                  Expanded(child: _dropdown(players, p1, (val) {
                    setState(() => p1 = val);
                    if(val != null) _fetchStats(val.id, true);
                  })),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("VS", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.redAccent, fontSize: 24, fontStyle: FontStyle.italic)),
                  ),
                  Expanded(child: _dropdown(players, p2, (val) {
                    setState(() => p2 = val);
                    if(val != null) _fetchStats(val.id, false);
                  })),
                ],
              ),
            ),
            
            // 2. KARŞILAŞTIRMA ALANI
            if (stats1 != null && stats2 != null)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Fotoğraflar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _playerHeader(p1!),
                        _playerHeader(p2!),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 10),
                    
                    // Renkli İstatistik Barları
                    _simpleStatRow("eFG %", stats1!['efgPercent'], stats2!['efgPercent'], "%"),
                    _simpleStatRow("TS %", stats1!['tsPercent'], stats2!['tsPercent'], "%"),
                    _simpleStatRow("FG %", stats1!['fgPercent'], stats2!['fgPercent'], "%"),
                    _simpleStatRow("Toplam Şut", stats1!['totalShots'], stats2!['totalShots'], ""),
                  ],
                ),
              )
            else
              const Expanded(child: Center(child: Text("Karşılaştırmak için iki oyuncu seçin", style: TextStyle(color: Colors.grey))))
          ],
        ),
      ),
    );
  }

  Widget _playerHeader(Player p) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2)),
          child: CircleAvatar(radius: 45, backgroundImage: NetworkImage(p.imageUrl)),
        ),
        const SizedBox(height: 10),
        Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _dropdown(List<Player> list, Player? selected, Function(Player?) onChange) {
    return DropdownButtonFormField<Player>(
      decoration: const InputDecoration(
        border: OutlineInputBorder(), 
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        filled: true,
        fillColor: Colors.black12
      ),
      isExpanded: true,
      value: selected,
      hint: const Text("Oyuncu Seç", style: TextStyle(fontSize: 14)),
      items: list.map((e) => DropdownMenuItem(value: e, child: Text(e.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: onChange,
    );
  }

  // --- RENKLİ BAR FONKSİYONU ---
  Widget _simpleStatRow(String label, dynamic val1, dynamic val2, String unit) {
    double v1 = double.tryParse(val1.toString()) ?? 0;
    double v2 = double.tryParse(val2.toString()) ?? 0;
    
    // RENK MANTIĞI: KİM BÜYÜKSE YEŞİL, KÜÇÜKSE KIRMIZI
    Color c1 = v1 >= v2 ? const Color(0xFF00D26A) : const Color(0xFFFF0000);
    Color c2 = v2 >= v1 ? const Color(0xFF00D26A) : const Color(0xFFFF0000);

    // Bar Genişlik Oranı
    double total = v1 + v2;
    if (total == 0) total = 1;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$val1$unit", style: TextStyle(color: c1, fontWeight: FontWeight.bold, fontSize: 18)),
              Text(label.toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
              Text("$val2$unit", style: TextStyle(color: c2, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  // Sol Bar
                  Expanded(flex: (v1 * 100).toInt(), child: Container(color: c1.withOpacity(0.8))),
                  const SizedBox(width: 4), // Boşluk
                  // Sağ Bar
                  Expanded(flex: (v2 * 100).toInt(), child: Container(color: c2.withOpacity(0.8))),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}