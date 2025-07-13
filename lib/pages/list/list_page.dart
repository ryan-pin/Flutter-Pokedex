import 'package:flutter/material.dart';
import 'package:pokedexflutter/models/pokemon.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key, required this.list});

  final List<Pokemon> list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listagem de Pokemons'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Fundo com imagem
          Positioned.fill(
            child: Image.asset('assets/images/telaList.png', fit: BoxFit.cover),
          ),
          // Lista de Pokemons
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
                shadowColor: Colors.black,
                elevation: 5,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/details');
              },
              child: const Text('Detalhar'),
            ),
          ),
        ],
      ),
    );
  }
}
