import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cfdi.dart';
import '../services/file_service.dart';

class CFDIActions extends StatelessWidget {
  final CFDI cfdi;

  const CFDIActions({
    Key? key,
    required this.cfdi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Botón para copiar UUID
        ElevatedButton.icon(
          icon: const Icon(Icons.copy),
          label: const Text('Copiar UUID'),
          onPressed: cfdi.timbreFiscalDigital?.uuid != null
              ? () {
                  Clipboard.setData(
                    ClipboardData(
                      text: cfdi.timbreFiscalDigital!.uuid!,
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('UUID copiado al portapapeles'),
                    ),
                  );
                }
              : null,
        ),
        const SizedBox(width: 8),
        // Botón para abrir el archivo XML
        ElevatedButton.icon(
          icon: const Icon(Icons.open_in_new),
          label: const Text('Abrir XML'),
          onPressed: cfdi.filePath != null
              ? () async {
                  final success =
                      await FileService.openFileWithDefaultApp(cfdi.filePath!);
                  if (!success) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo abrir el archivo'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              : null,
        ),
      ],
    );
  }
}
