import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> pokemon;
  final List<Map<String, dynamic>> pokemonList;
  final int currentIndex;

  const DetailPage({
    super.key,
    required this.pokemon,
    required this.pokemonList,
    required this.currentIndex,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Map<String, dynamic> currentPokemon;
  late int currentIndex;
  bool isFavorite = false;
  Map<String, dynamic>? pokemonDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentPokemon = widget.pokemon;
    currentIndex = widget.currentIndex;
    
    print('=== DEBUG DetailPage ===');
    print('Pokémon atual: ${currentPokemon['name']}');
    print('URL: ${currentPokemon['url']}');
    print('Lista de Pokémon tem ${widget.pokemonList.length} items');
    print('Index atual: $currentIndex');
    
    _loadPokemonDetails();
    _checkIfFavorite();
  }

  Future<void> _loadPokemonDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Verifica se a URL existe e não é nula
      final pokemonUrl = currentPokemon['url'];
      if (pokemonUrl == null || pokemonUrl.toString().isEmpty) {
        print('URL do Pokémon é nula ou vazia');
        setState(() {
          isLoading = false;
        });
        return;
      }

      print('Carregando detalhes do Pokémon: $pokemonUrl');
      final response = await http.get(Uri.parse(pokemonUrl.toString()));
      print('Status da resposta: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Dados carregados com sucesso para: ${data['name']}');
        
        setState(() {
          pokemonDetails = data;
          isLoading = false;
        });
      } else {
        print('Erro HTTP: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar detalhes do Pokémon: $e');
      print('Dados do Pokémon atual: $currentPokemon');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToNext() {
    if (currentIndex < widget.pokemonList.length - 1) {
      print('Navegando para o próximo Pokémon. Index atual: $currentIndex');
      setState(() {
        currentIndex++;
        currentPokemon = widget.pokemonList[currentIndex];
      });
      print('Novo Pokémon: ${currentPokemon['name']}, URL: ${currentPokemon['url']}');
      _loadPokemonDetails();
      _checkIfFavorite();
    }
  }

  void _navigateToPrevious() {
    if (currentIndex > 0) {
      print('Navegando para o Pokémon anterior. Index atual: $currentIndex');
      setState(() {
        currentIndex--;
        currentPokemon = widget.pokemonList[currentIndex];
      });
      print('Novo Pokémon: ${currentPokemon['name']}, URL: ${currentPokemon['url']}');
      _loadPokemonDetails();
      _checkIfFavorite();
    }
  }

  Future<void> _checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesString = prefs.getString('favorite_pokemon') ?? '[]';
    final favorites = List<String>.from(jsonDecode(favoritesString));

    setState(() {
      isFavorite = favorites.contains(currentPokemon['name']);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesString = prefs.getString('favorite_pokemon') ?? '[]';
    final favorites = List<String>.from(jsonDecode(favoritesString));

    if (isFavorite) {
      favorites.remove(currentPokemon['name']);
    } else {
      favorites.add(currentPokemon['name']);
    }

    await prefs.setString('favorite_pokemon', jsonEncode(favorites));

    setState(() {
      isFavorite = !isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? '${currentPokemon['name']} adicionado aos favoritos!'
              : '${currentPokemon['name']} removido dos favoritos!',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getPokemonImageUrl() {
    if (pokemonDetails != null) {
      // Tenta acessar a imagem oficial de alta qualidade primeiro
      try {
        final officialArtwork = pokemonDetails!['sprites']?['other']?['official-artwork']?['front_default'];
        if (officialArtwork != null && officialArtwork.toString().isNotEmpty) {
          return officialArtwork.toString();
        }
      } catch (e) {
        print('Erro ao acessar official-artwork: $e');
      }
      
      // Fallback para sprite padrão
      try {
        final frontDefault = pokemonDetails!['sprites']?['front_default'];
        if (frontDefault != null && frontDefault.toString().isNotEmpty) {
          return frontDefault.toString();
        }
      } catch (e) {
        print('Erro ao acessar front_default: $e');
      }
    }
    
    // Último fallback - extrai ID da URL e monta URL manualmente
    final String url = currentPokemon['url']?.toString() ?? '';
    if (url.isNotEmpty) {
      final RegExp regExp = RegExp(r'/(\d+)/');
      final match = regExp.firstMatch(url);
      
      if (match != null) {
        final id = match.group(1);
        return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
      }
    }
    
    print('Não foi possível obter URL da imagem para: ${currentPokemon['name']}');
    return '';
  }

  List<String> _getPokemonTypes() {
    if (pokemonDetails != null) {
      final types = pokemonDetails!['types'] as List;
      return types.map((type) => type['type']['name'].toString()).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _navigateToPrevious();
          } else if (details.primaryVelocity! < 0) {
            _navigateToNext();
          }
        },
        child: Stack(
          children: [
            // Fundo com imagem vermelha decorativa
            Positioned.fill(
              child: Image.asset(
                'assets/images/telaList.png',
                fit: BoxFit.cover,
              ),
            ),
            // Botão FAV no canto superior direito
            Positioned(
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: _toggleFavorite,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isFavorite ? Colors.red : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Text(
                    'FAV',
                    style: TextStyle(
                      color: isFavorite ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            // Botão de voltar no canto superior esquerdo
            Positioned(
              top: 50,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ),
            // Conteúdo da tela
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 80),

                  // Imagem do Pokémon
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[100],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Image.network(
                                    _getPokemonImageUrl(),
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentPokemon['name'].toString().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Tipo(s):',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (!isLoading && _getPokemonTypes().isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: _getPokemonTypes()
                                .map((type) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.blue),
                                      ),
                                      child: Text(
                                        type.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Botões
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: currentIndex > 0 ? _navigateToPrevious : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('< Anterior'),
                        ),
                        ElevatedButton(
                          onPressed:
                              currentIndex < widget.pokemonList.length - 1
                                  ? _navigateToNext
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Próximo >'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
