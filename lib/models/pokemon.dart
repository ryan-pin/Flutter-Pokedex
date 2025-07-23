 class Pokemon {
  final String name;
  final String type;
  final String image;

  Pokemon({
    required this.name,
    required this.type,
    required this.image,
 });

  static Pokemon fromJson(pokemonData) {
    return Pokemon(
      name: pokemonData['name'] ?? '',
      type: pokemonData['type'] ?? '',
      image: pokemonData['image'] ?? '',
    );
  }
}