import 'dart:io';
import 'package:comparador_cfdis/utils/log.dart';
import 'package:path/path.dart' as path;

class FileService {
  /// Abre un archivo con la aplicación predeterminada de Windows
  static Future<bool> openFileWithDefaultApp(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        Log.logError('El archivo no existe: $filePath');
        return false;
      }

      // Imprimir la ruta para depuración
      Log.logInfo('Intentando abrir: $filePath');

      if (Platform.isWindows) {
        // Usar Process.run directo en Windows para evitar problemas de symlinks
        final process = await Process.run(
          'cmd',
          [
            '/c',
            'start',
            '',
            filePath,
          ],
          runInShell: true,
        );

        Log.logInfo('Resultado de abrir archivo: ${process.exitCode}');
        return process.exitCode == 0;
      } else {
        // En otras plataformas, usar url_launcher o similar
        throw UnsupportedError('Plataforma no soportada para abrir archivos');
      }
    } catch (e) {
      Log.logError('Error al abrir el archivo: $e');
      return false;
    }
  }

  /// Obtiene el nombre del archivo desde una ruta
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }
}
