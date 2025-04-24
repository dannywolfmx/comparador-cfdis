import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
import 'package:comparador_cfdis/bloc/cfdi_state.dart';
import 'package:comparador_cfdis/providers/column_visibility_provider.dart';
import 'package:comparador_cfdis/widgets/adaptive_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ColumnVisibilityProvider(),
      child: Builder(
        builder: (context) => Scaffold(
          body: _buildBody(context),
          floatingActionButton: _buildFloatingActionButtons(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<CFDIBloc, CFDIState>(builder: (context, state) {
      switch (state.runtimeType) {
        case CFDIInitial:
          return _buildInitialState(context);
        case CFDILoading:
          return _buildLoadingState();
        case CFDILoaded:
          return _buildLoadedState(state as CFDILoaded);
        case CFDIError:
          return _buildErrorState(state as CFDIError, context);
        default:
          return Container();
      }
    });
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 80.0,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16.0),
            Text(
              'No hay CFDIs cargados',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24.0),
            loadButtons(context),
          ],
        ),
      ),
    );
  }

  Widget loadButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            context.read<CFDIBloc>().add(LoadCFDIsFromDirectory());
          },
          icon: const Icon(Icons.folder_open),
          label: const Text('Cargar desde directorio'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size(240, 48),
          ),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton.icon(
          onPressed: () {
            context.read<CFDIBloc>().add(LoadCFDIsFromFile());
          },
          icon: const Icon(Icons.file_upload),
          label: const Text('Cargar archivo XML'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size(240, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildLoadedState(CFDILoaded state) {
    return AdaptiveCFDIView(cfdis: state.cfdis);
  }

  Widget _buildErrorState(CFDIError state, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: ${state.message}',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          loadButtons(context)
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context) {
    return BlocBuilder<CFDIBloc, CFDIState>(builder: (context, state) {
      if (state is CFDILoaded) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAddFileButton(context),
            const SizedBox(height: 10),
            _buildAddDirectoryButton(context),
          ],
        );
      }
      return Container();
    });
  }

  Widget _buildAddFileButton(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'addFile',
      onPressed: () {
        context.read<CFDIBloc>().add(LoadCFDIsFromFile());
      },
      tooltip: 'Añadir archivo CFDI',
      child: const Icon(Icons.add_to_photos),
    );
  }

  Widget _buildAddDirectoryButton(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'addDirectory',
      onPressed: () {
        context.read<CFDIBloc>().add(LoadCFDIsFromDirectory());
      },
      tooltip: 'Cargar directorio',
      child: const Icon(Icons.create_new_folder),
    );
  }
}
