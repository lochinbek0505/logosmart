class Level {
  final int id;
  final double dx;
  final double dy;
  final int stars;
  final bool locked;
  final String skin;

  const Level({
    required this.id,
    required this.dx,
    required this.dy,
    required this.stars,
    required this.locked,
    required this.skin,
  });
}
