import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
import 'package:comparador_cfdis/bloc/cfdi_state.dart';
import 'package:comparador_cfdis/providers/column_visibility_provider.dart';
import 'package:comparador_cfdis/screens/cfdi_list_screen.dart';
import 'package:comparador_cfdis/widgets/cfdi_list.dart';
import 'package:comparador_cfdis/widgets/modern/modern_card.dart';
import 'package:comparador_cfdis/widgets/modern/modern_buttons.dart';
import 'package:comparador_cfdis/widgets/modern/modern_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ColumnVisibilityProvider(),
      child: Scaffold(
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<CFDIBloc, CFDIState>(
      builder: (context, state) {
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
      },
    );
  }

  Widget _buildInitialState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: MaxWidthContainer(
        maxWidth: 600,
        child: ModernCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: 80.0,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24.0),
              Text(
                'No hay CFDIs cargados',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Selecciona una opción para comenzar',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32.0),
              loadButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget loadButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ModernButton(
          text: 'Cargar desde directorio',
          icon: Icons.folder_open,
          onPressed: () {
            context.read<CFDIBloc>().add(LoadCFDIsFromDirectory());
          },
          fullWidth: true,
        ),
        const SizedBox(height: 16.0),
        ModernButton(
          text: 'Cargar archivo XML',
          icon: Icons.file_upload,
          style: ModernButtonStyle.outlined,
          onPressed: () {
            context.read<CFDIBloc>().add(LoadCFDIsFromFile());
          },
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Builder(
      builder: (context) => Center(
        child: ModernCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Cargando CFDIs...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedState(CFDILoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Si el ancho es menor que un umbral (por ejemplo, 600), mostramos lista
        if (constraints.maxWidth < 600) {
          return CFDIListView(cfdis: state.cfdis);
        } else {
          // Si hay espacio suficiente, mostramos la tabla
          return CFDITableView(cfdis: state.cfdis);
        }
      },
    );
  }

  Widget _buildErrorState(CFDIError state, BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: MaxWidthContainer(
        maxWidth: 600,
        child: ModernCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar CFDIs',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              loadButtons(context),
            ],
          ),
        ),
      ),
    );
  }
}
