import 'package:flutter/material.dart';
import 'package:pokedexflutter/models/pokemon.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Pokemon> pokemonList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPokemons();
  }

  Future<void> fetchPokemons() async {
    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=151'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        List<Pokemon> pokemons = [];
        
        for (var pokemon in results) {
          final pokemonResponse = await http.get(Uri.parse(pokemon['url']));
          if (pokemonResponse.statusCode == 200) {
            final pokemonData = json.decode(pokemonResponse.body);
            pokemons.add(Pokemon.fromJson(pokemonData));
          }
        }
        
        setState(() {
          pokemonList = pokemons;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

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
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ListView.builder(
              itemCount: pokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = pokemonList[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      pokemon.name?.capitalize() ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      pokemon.type?.capitalize() ?? '',
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/details',
                        arguments: pokemon,
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
