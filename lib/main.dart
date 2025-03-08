import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:printing/printing.dart';
import 'screens/cfdi_list_screen.dart';
import 'models/cfdi.dart';

void main() async {
  // Es necesario asegurarse de que los widgets de Flutter estén inicializados
  // antes de hacer cualquier operación con plugins nativos
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar el plugin de impresión con una prueba simple
  try {
    // Esto fuerza la inicialización del plugin
    await Printing.listPrinters();
    debugPrint('Printing plugin inicializado correctamente');
  } catch (e) {
    debugPrint('Error al inicializar printing plugin: $e');
  }

  // Continuamos con el inicio normal de la aplicación
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comparador CFDIs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CFDIListScreen(),
    );
  }
}
