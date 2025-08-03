import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comparador_cfdis/bloc/diot_bloc.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/widgets/diot_configuration_panel.dart';
import 'package:comparador_cfdis/widgets/diot_preview_table.dart';
import 'package:comparador_cfdis/widgets/diot_validation_panel.dart';
import 'package:comparador_cfdis/widgets/diot_export_panel.dart';

class DIOTScreen extends StatefulWidget {
  final List<CFDI> cfdis;

  const DIOTScreen({Key? key, required this.cfdis}) : super(key: key);

  @override
  State<DIOTScreen> createState() => _DIOTScreenState();
}

class _DIOTScreenState extends State<DIOTScreen> {
  DIOTBloc? _diotBloc;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Generador DIOT 2025'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.settings), text: 'Configuración'),
              Tab(icon: Icon(Icons.table_view), text: 'Vista Previa'),
              Tab(icon: Icon(Icons.warning), text: 'Validaciones'),
              Tab(icon: Icon(Icons.download), text: 'Exportar'),
            ],
          ),
        ),
        body: widget.cfdis.isEmpty
            ? const _NoCFDIsLoadedWidget()
            : _buildDIOTContent(),
      ),
    );
  }

  Widget _buildDIOTContent() {
    // Crear o reutilizar el DIOTBloc
    _diotBloc ??= DIOTBloc(widget.cfdis);

    return BlocProvider.value(
      value: _diotBloc!,
      child: TabBarView(
        children: [
          DIOTConfigurationPanel(
            cfdis: widget.cfdis,
          ),
          const DIOTPreviewTable(),
          const DIOTValidationPanel(),
          const DIOTExportPanel(),
        ],
      ),
    );
  }
}

class _NoCFDIsLoadedWidget extends StatelessWidget {
  const _NoCFDIsLoadedWidget();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay CFDIs cargados',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Para generar una DIOT, primero debes cargar los CFDIs desde la pantalla principal.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cargar CFDIs'),
          ),
        ],
      ),
    );
  }
}
