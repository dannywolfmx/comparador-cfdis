import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/filter_template_bloc.dart';
import 'package:comparador_cfdis/bloc/filter_template_event.dart';
import 'package:comparador_cfdis/models/filter.dart';
import 'package:comparador_cfdis/repositories/cfdi_repository.dart';
import 'package:comparador_cfdis/screens/start_screen.dart';
import 'package:comparador_cfdis/services/configuration_service.dart';
import 'package:comparador_cfdis/services/filter_template_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

void main() async {
  // Asegurar que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar logger global
  Logger.level = Level.info;
  final logger = Logger();

  try {
    // Inicializar servicios
    await ConfigurationService.init();
    logger.i('Servicios inicializados correctamente');

    // Inicializar repositorio
    final cfdiRepository = CFDIRepository();
    final filters = <FilterOption>{};
    final filterTemplateService = FilterTemplateService();

    runApp(
      MyApp(
        cfdiRepository: cfdiRepository,
        filters: filters,
        filterTemplateService: filterTemplateService,
      ),
    );
  } catch (e, stackTrace) {
    logger.e('Error durante la inicialización',
        error: e, stackTrace: stackTrace);

    // Ejecutar app con configuración mínima en caso de error
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  final CFDIRepository cfdiRepository;
  final Set<FilterOption> filters;
  final FilterTemplateService filterTemplateService;

  const MyApp({
    super.key,
    required this.cfdiRepository,
    required this.filters,
    required this.filterTemplateService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comparador CFDIs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.white,
          elevation: 2.0,
        ),
      ),
      home: Builder(
        builder: (context) {
          final filterTemplateBloc = FilterTemplateBloc(filterTemplateService)
            ..add(LoadFilterTemplates());

          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: filterTemplateBloc),
              BlocProvider(
                create: (context) =>
                    CFDIBloc(cfdiRepository, filters, filterTemplateBloc),
              ),
            ],
            child: const StartScreen(),
          );
        },
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error - Comparador CFDIs',
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error al inicializar la aplicación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Por favor, reinicia la aplicación',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Reiniciar la aplicación
                  main();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
