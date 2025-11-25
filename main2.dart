import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/api_service.dart';
import 'data/player_model.dart';

// API Servisini sunan sağlayıcı
final apiServiceProvider = Provider((ref) => ApiService());

// Oyuncu listesini asenkron getiren sağlayıcı
final playersProvider = FutureProvider<List<Player>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  return api.getPlayers();
});