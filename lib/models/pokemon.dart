 class Pokemon {
  final String name;
  final String type;
  final String image;
  final String? url;

  Pokemon({
    required this.name,
    required this.type,
    required this.image,
    this.url,
 });

  static Pokemon fromJson(pokemonData, {String? originalUrl}) {
    return Pokemon(
      name: pokemonData['name'] ?? '',
      type: pokemonData['types'] != null && pokemonData['types'].isNotEmpty 
          ? pokemonData['types'][0]['type']['name'] ?? ''
          : '',
      image: pokemonData['sprites']?['other']?['official-artwork']?['front_default'] ?? '',
      url: originalUrl,
    );
  }

  toJson() {
    return {
      'name': name,
      'type': type,
      'image': image,
      'url': url,
    };
  }
}