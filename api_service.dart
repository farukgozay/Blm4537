import 'dart:io';
import 'package:dio/dio.dart';
import 'player_model.dart';

class ApiService {
  // Windows'ta çalıştığın için localhost
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:5131/api'));

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // 1. LOGIN
  Future<String?> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username, 'password': password
      });
      return response.data.toString();
    } catch (e) { return null; }
  }

  // 2. GET PLAYERS
  Future<List<Player>> getPlayers() async {
    try {
      final response = await _dio.get('/players');
      List<dynamic> data = response.data;
      return data.map((json) => Player.fromJson(json)).toList();
    } catch (e) { return []; }
  }

  // 3. GET DETAILS
  Future<Map<String, dynamic>?> getPlayerDetails(int id) async {
    try {
      final response = await _dio.get('/players/$id/details');
      return response.data;
    } catch (e) { return null; }
  }

  // 4. ADD PLAYER
  Future<Player?> addPlayer(Map<String, dynamic> playerData) async {
    try {
      final response = await _dio.post('/players', data: playerData);
      return Player.fromJson(response.data);
    } catch (e) { return null; }
  }

  // 5. UPLOAD SHOTS
  Future<bool> uploadShots(int playerId, File file) async {
    try {
      String fileName = file.path.split('\\').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });
      await _dio.post('/shots/upload/$playerId', data: formData);
      return true;
    } catch (e) { return false; }
  }

  // --- 6. OYUNCU SİL (İŞTE EKSİK OLAN BU KISIMDI) ---
  Future<bool> deletePlayer(int id) async {
    try {
      await _dio.delete('/players/$id');
      return true;
    } catch (e) {
      print("Silme Hatası: $e");
      return false;
    }
  }
}