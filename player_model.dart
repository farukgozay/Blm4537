class Player {
  final int id;
  final String name;
  final String team;
  final String position;
  final String imageUrl;

  Player({
    required this.id,
    required this.name,
    required this.team,
    required this.position,
    required this.imageUrl,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      team: json['team'],
      position: json['position'] ?? 'Bilinmiyor', // Null gelirse patlamasın
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
    );
  }
}