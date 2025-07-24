import 'package:flutter/material.dart';
import 'package:pokedexflutter/pages/details/detail_page.dart';
import 'package:pokedexflutter/pages/home/home_page.dart';
import 'package:pokedexflutter/pages/list/list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokedex Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/List': (context) => const ListPage(),
        '/details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DetailPage(
            pokemon: args['pokemon'],
            pokemonList: args['pokemonList'],
            currentIndex: args['currentIndex'],
          );
        },
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
    );
  }
}
