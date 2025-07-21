import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
import 'package:comparador_cfdis/bloc/cfdi_state.dart';
import 'package:comparador_cfdis/theme/app_dimensions.dart';

class GlobalSearchWidget extends StatefulWidget {
  const GlobalSearchWidget({super.key});

  @override
  State<GlobalSearchWidget> createState() => _GlobalSearchWidgetState();
}

class _GlobalSearchWidgetState extends State<GlobalSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _lastQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<CFDIBloc, CFDIState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              Expanded(
                child: Semantics(
                  label: 'Campo de búsqueda global de CFDIs',
                  hint: 'Ingrese UUID, RFC o razón social para buscar',
                  textField: true,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Buscar UUID, RFC, razón social...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    style: theme.textTheme.bodyMedium,
                    onChanged: _onSearchChanged,
                    onSubmitted: _onSearchSubmitted,
                    textInputAction: TextInputAction.search,
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  tooltip: 'Limpiar búsqueda',
                  onPressed: _clearSearch,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _onSearchChanged(String query) {
    // Debounce la búsqueda para evitar demasiadas llamadas
    Future.delayed(AppAnimations.medium, () {
      if (query == _controller.text && query != _lastQuery) {
        _performSearch(query);
        _lastQuery = query;
      }
    });
  }

  void _onSearchSubmitted(String query) {
    _performSearch(query);
    _lastQuery = query;
    _focusNode.unfocus();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      context.read<CFDIBloc>().add(ClearGlobalSearch());
    } else {
      context.read<CFDIBloc>().add(SearchGlobal(query.trim()));
    }
  }

  void _clearSearch() {
    setState(() {
      _controller.clear();
      _lastQuery = '';
    });
    context.read<CFDIBloc>().add(ClearGlobalSearch());
    _focusNode.unfocus();
  }
}
