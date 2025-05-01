import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/models/filter.dart';
import 'package:comparador_cfdis/repositories/cfdi_repository.dart';
import 'package:comparador_cfdis/screens/start_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  final cfdiRepository = CFDIRepository();
  // Es necesario asegurarse de que los widgets de Flutter estén inicializados
  // antes de hacer cualquier operación con plugins nativos
  WidgetsFlutterBinding.ensureInitialized();

  // Continuamos con el inicio normal de la aplicación
  runApp(MyApp(
    cfdiRepository: cfdiRepository,
  ));
}

class MyApp extends StatelessWidget {
  final CFDIRepository cfdiRepository;
  final Set<FilterOption> filters = {};

  MyApp({Key? key, required this.cfdiRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comparador CFDIs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Agregamos configuración adicional para el drawer
        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.white,
          elevation: 2.0,
        ),
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => CFDIBloc(cfdiRepository, filters)),
        ],
        child: const StartScreen(),
      ),
    );
  }
}
