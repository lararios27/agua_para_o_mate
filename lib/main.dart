import 'package:flutter/material.dart';

import 'screens/decibelimetro_page.dart';

void main() {
  runApp(const DecibelimetroApp());
}

class DecibelimetroApp extends StatefulWidget {
  const DecibelimetroApp({super.key});

  @override
  State<DecibelimetroApp> createState() => _DecibelimetroAppState();
}

class _DecibelimetroAppState extends State<DecibelimetroApp> {
  bool modoEscuro = false;

  void trocarTema() {
    setState(() {
      modoEscuro = !modoEscuro;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Decibelímetro',
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      themeMode: modoEscuro ? ThemeMode.dark : ThemeMode.light,
      home: DecibelimetroPage(
        modoEscuro: modoEscuro,
        trocarTema: trocarTema,
      ),
    );
  }
}