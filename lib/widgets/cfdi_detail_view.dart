import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cfdi.dart';
import '../services/file_service.dart';

class CFDIDetailView extends StatelessWidget {
  final CFDI cfdi;

  const CFDIDetailView({
    Key? key,
    required this.cfdi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado con información principal del CFDI
        _buildHeaderSection(),

        // Sección UUID con botones para copiar y abrir archivo
        _buildUuidSection(context),

        // Resto del contenido del CFDI
        // ...existing code...
      ],
    );
  }

  Widget _buildUuidSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'UUID del CFDI:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(cfdi.timbreFiscalDigital?.uuid ?? 'No disponible'),
          const SizedBox(height: 8),
          Row(
            children: [
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
              ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir XML'),
                onPressed: cfdi.filePath != null
                    ? () async {
                        final success =
                            await FileService.openFileWithDefaultApp(
                                cfdi.filePath!);
                        if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No se pudo abrir el archivo'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOpenFileButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.open_in_new),
        label: Text(
            'Abrir XML ${cfdi.filePath != null ? "(${FileService.getFileName(cfdi.filePath!)})" : ""}'),
        onPressed: cfdi.filePath != null
            ? () async {
                final success =
                    await FileService.openFileWithDefaultApp(cfdi.filePath!);
                if (!success) {
                  // Manejar el error si es necesario
                }
              }
            : null,
      ),
    );
  }

  Widget _buildHeaderSection() {
    // ...existing code...
    return Container(); // Reemplazar con el código actual
  }

  // ...existing code...
}
