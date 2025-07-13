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
        '/List': (context) => const ListPage(list: [],),
        '/details': (context) => const DetailPage(), // Placeholder for details page
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
    );
  }
}
