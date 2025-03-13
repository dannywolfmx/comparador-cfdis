//Widget to contain the buttons to load the CFDI files
import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadButtons extends StatelessWidget {
  const LoadButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      spacing: 10.0,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            context.read<CFDIBloc>().add(LoadCFDIsFromDirectory());
          },
          icon: const Icon(Icons.folder_open),
          label: const Text('Cargar desde directorio'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            context.read<CFDIBloc>().add(LoadCFDIsFromFile());
          },
          icon: const Icon(Icons.file_upload),
          label: const Text('Cargar archivo XML'),
        ),
      ],
    );
  }
}
