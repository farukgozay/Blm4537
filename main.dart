import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/api_service.dart';
import 'screens/intro_screen.dart';
import 'screens/player_detail_screen.dart';
import 'data/player_model.dart';

final apiServiceProvider = Provider((ref) => ApiService());

void main() {
  runApp(const ProviderScope(child: ShotForgeApp()));
}

class ShotForgeApp extends StatelessWidget {
  const ShotForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShotForge Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF007BFF),
        cardColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF007BFF),
          secondary: Color(0xFF00D26A),
        ),
      ),
      home: const IntroScreen(),
    );
  }
}

// --- GÜNCELLENMİŞ KART (SİLME ÖZELLİKLİ) ---
class PlayerCard extends StatefulWidget {
  final Player player;
  final VoidCallback? onDelete; // Silme fonksiyonu dışarıdan gelecek

  const PlayerCard({super.key, required this.player, this.onDelete});

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerDetailScreen(playerId: widget.player.id)));
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(color: const Color(0xFF007BFF).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Stack(
            children: [
              // İÇERİK
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.player.imageUrl,
                        width: 80, height: 80, fit: BoxFit.cover,
                        errorBuilder: (c, o, s) => Container(width: 80, height: 80, color: Colors.grey[800], child: const Icon(Icons.person)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.player.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text("${widget.player.team} | ${widget.player.position}", style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF007BFF)),
                  ],
                ),
              ),

              // SİLME BUTONU (SAĞ ÜST KÖŞE)
              if (widget.onDelete != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                    onPressed: widget.onDelete,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}