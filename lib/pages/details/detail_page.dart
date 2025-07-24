import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    currentPokemon = widget.pokemon;
    currentIndex = widget.currentIndex;
  }

  void _navigateToNext() {
    if (currentIndex < widget.pokemonList.length - 1) {
      setState(() {
        currentIndex++;
        currentPokemon = widget.pokemonList[currentIndex];
      });
    }
  }

  void _navigateToPrevious() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        currentPokemon = widget.pokemonList[currentIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentPokemon['name'] ?? 'Detalhe do Pokémon'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Arrastar para a direita - voltar
            _navigateToPrevious();
          } else if (details.primaryVelocity! < 0) {
            // Arrastar para a esquerda - próximo
            _navigateToNext();
          }
        },
        child: Stack(
          children: [
            const SizedBox(height: 50),
            // Fundo com imagem vermelha decorativa
            Positioned.fill(
              child: Image.asset(
                'assets/images/telaList.png', // imagem de fundo
                fit: BoxFit.cover,
              ),
            ),
            // Conteúdo da tela
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Informações do Pokémon
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
                        Text(
                          currentPokemon['name'].toString().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tipo(s):',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 5),
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
                          onPressed: currentIndex > 0 
                            ? _navigateToPrevious
                            : () => Navigator.pop(context),
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
                          child: const Text('< Voltar'),
                        ),
                        ElevatedButton(
                          onPressed: currentIndex < widget.pokemonList.length - 1
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
