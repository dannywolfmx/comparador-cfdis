import 'impuesto_concepto.dart';
import 'traslado_concepto.dart';
import 'dart:developer' as developer;

class Concepto {
  final String claveProdServ;
  final String noIdentificacion;
  final int cantidad;
  final String claveUnidad;
  final String unidad;
  final String descripcion;
  final double valorUnitario;
  final double importe;
  final List<ImpuestoConcepto> impuestos;
  final List<TrasladoConcepto> traslados;
  final String objetoImp;

  Concepto({
    required this.claveProdServ,
    required this.noIdentificacion,
    required this.cantidad,
    required this.claveUnidad,
    required this.unidad,
    required this.descripcion,
    required this.valorUnitario,
    required this.importe,
    required this.impuestos,
    required this.traslados,
    required this.objetoImp,
  });

  factory Concepto.fromJson(Map<String, dynamic> json) {
    List<ImpuestoConcepto> impuestos = [];
    List<TrasladoConcepto> traslados = [];

    // Estructura exacta: concepto > impuestos > traslados > traslado
    if (json['impuestos'] != null) {
      // Primero intentar la estructura en minúsculas (común en XML parseados)
      if (json['impuestos']['traslados'] != null) {
        final trasladosJson = json['impuestos']['traslados']['traslado'];
        if (trasladosJson is List) {
          for (var traslado in trasladosJson) {
            traslados.add(TrasladoConcepto.fromJson(traslado));
          }
        } else if (trasladosJson != null) {
          traslados.add(TrasladoConcepto.fromJson(trasladosJson));
        }
      }
      // Estructura en mayúsculas (también común)
      else if (json['impuestos']['Traslados'] != null) {
        final trasladosJson = json['impuestos']['Traslados']['Traslado'];
        if (trasladosJson is List) {
          for (var traslado in trasladosJson) {
            traslados.add(TrasladoConcepto.fromJson(traslado));
          }
        } else if (trasladosJson != null) {
          traslados.add(TrasladoConcepto.fromJson(trasladosJson));
        }
      }
    }
    // Estructura alternativa en mayúsculas
    else if (json['Impuestos'] != null) {
      if (json['Impuestos']['Traslados'] != null) {
        final trasladosJson = json['Impuestos']['Traslados']['Traslado'];
        if (trasladosJson is List) {
          for (var traslado in trasladosJson) {
            traslados.add(TrasladoConcepto.fromJson(traslado));
          }
        } else if (trasladosJson != null) {
          traslados.add(TrasladoConcepto.fromJson(trasladosJson));
        }
      }
    }

    // Manejar retenciones
    if (json['Impuestos'] != null) {
      if (json['Impuestos']['Retenciones'] != null) {
        final retenciones = json['Impuestos']['Retenciones']['Retencion'];
        if (retenciones is List) {
          for (var retencion in retenciones) {
            impuestos.add(ImpuestoConcepto.fromJson(retencion, false));
          }
        } else if (retenciones != null) {
          impuestos.add(ImpuestoConcepto.fromJson(retenciones, false));
        }
      }
      // Formato alternativo para retenciones
      else if (json['Impuestos']['Retencion'] != null) {
        final retenciones = json['Impuestos']['Retencion'];
        if (retenciones is List) {
          for (var retencion in retenciones) {
            impuestos.add(ImpuestoConcepto.fromJson(retencion, false));
          }
        } else if (retenciones != null) {
          impuestos.add(ImpuestoConcepto.fromJson(retenciones, false));
        }
      }
    }

    // Parse values with better error handling for the various field types
    String claveProdServ = json['ClaveProdServ']?.toString() ?? '';
    String noIdentificacion = json['NoIdentificacion']?.toString() ?? '';

    int cantidad;
    try {
      cantidad = int.parse(json['Cantidad']?.toString() ?? '0');
    } catch (e) {
      developer.log('Error parsing cantidad: ${e.toString()}');
      cantidad = 0;
    }

    String claveUnidad = json['ClaveUnidad']?.toString() ?? '';
    String unidad = json['Unidad']?.toString() ?? '';
    String descripcion = json['Descripcion']?.toString() ?? '';

    double valorUnitario;
    try {
      valorUnitario = double.parse(
          json['ValorUnitario']?.toString().replaceAll(',', '') ?? '0.0');
    } catch (e) {
      developer.log('Error parsing valorUnitario: ${e.toString()}');
      valorUnitario = 0.0;
    }

    double importe;
    try {
      importe = double.parse(
          json['Importe']?.toString().replaceAll(',', '') ?? '0.0');
    } catch (e) {
      developer.log('Error parsing importe: ${e.toString()}');
      importe = 0.0;
    }

    String objetoImp = json['ObjetoImp']?.toString() ?? '01';

    return Concepto(
      claveProdServ: claveProdServ,
      noIdentificacion: noIdentificacion,
      cantidad: cantidad,
      claveUnidad: claveUnidad,
      unidad: unidad,
      descripcion: descripcion,
      valorUnitario: valorUnitario,
      importe: importe,
      impuestos: impuestos,
      traslados: traslados,
      objetoImp: objetoImp,
    );
  }

  // Static method to parse a list of concepts from different CFDI formats
  static List<Concepto> parseConceptos(Map<String, dynamic> cfdi) {
    List<Concepto> conceptos = [];

    try {
      // Estructura exacta: Conceptos > concepto
      if (cfdi['Conceptos'] != null) {
        var conceptosData = cfdi['Conceptos'];

        // Para 'concepto' en minúsculas (común en XML parseados)
        if (conceptosData['concepto'] != null) {
          var conceptoData = conceptosData['concepto'];
          if (conceptoData is List) {
            for (var concepto in conceptoData) {
              conceptos.add(Concepto.fromJson(concepto));
              developer.log('Added concepto from minúsculas path');
            }
          } else {
            conceptos.add(Concepto.fromJson(conceptoData));
            developer.log('Added single concepto from minúsculas path');
          }
        }
        // Para 'Concepto' en mayúsculas
        else if (conceptosData['Concepto'] != null) {
          var conceptoData = conceptosData['Concepto'];
          if (conceptoData is List) {
            for (var concepto in conceptoData) {
              conceptos.add(Concepto.fromJson(concepto));
              developer.log('Added concepto from mayúsculas path');
            }
          } else {
            conceptos.add(Concepto.fromJson(conceptoData));
            developer.log('Added single concepto from mayúsculas path');
          }
        }
      }

      // Estructura alternativa con conceptos en minúsculas
      else if (cfdi['conceptos'] != null) {
        var conceptosData = cfdi['conceptos'];
        if (conceptosData['concepto'] != null) {
          var conceptoData = conceptosData['concepto'];
          if (conceptoData is List) {
            for (var concepto in conceptoData) {
              conceptos.add(Concepto.fromJson(concepto));
              developer.log('Added concepto from lowercase path');
            }
          } else {
            conceptos.add(Concepto.fromJson(conceptoData));
            developer.log('Added single concepto from lowercase path');
          }
        }
      }

      // Soporte para cfdi: prefijo (común en XML)
      else if (cfdi['cfdi:Conceptos'] != null) {
        var conceptosData = cfdi['cfdi:Conceptos'];
        if (conceptosData['cfdi:Concepto'] != null) {
          var conceptoData = conceptosData['cfdi:Concepto'];
          if (conceptoData is List) {
            for (var concepto in conceptoData) {
              conceptos.add(Concepto.fromJson(concepto));
            }
          } else {
            conceptos.add(Concepto.fromJson(conceptoData));
          }
        }
      }

      // Estructura anidada desde Comprobante
      else if (cfdi['Comprobante'] != null) {
        if (cfdi['Comprobante']['Conceptos'] != null) {
          var conceptosData = cfdi['Comprobante']['Conceptos'];
          if (conceptosData['Concepto'] != null) {
            var conceptoData = conceptosData['Concepto'];
            if (conceptoData is List) {
              for (var concepto in conceptoData) {
                conceptos.add(Concepto.fromJson(concepto));
              }
            } else {
              conceptos.add(Concepto.fromJson(conceptoData));
            }
          }
        }
      }

      // Verificar si hay un objeto _declaration que contiene el CFDI real
      else if (cfdi['_declaration'] != null &&
          cfdi['cfdi:Comprobante'] != null) {
        if (cfdi['cfdi:Comprobante']['cfdi:Conceptos'] != null) {
          var conceptosData = cfdi['cfdi:Comprobante']['cfdi:Conceptos'];
          if (conceptosData['cfdi:Concepto'] != null) {
            var conceptoData = conceptosData['cfdi:Concepto'];
            if (conceptoData is List) {
              for (var concepto in conceptoData) {
                conceptos.add(Concepto.fromJson(concepto));
              }
            } else {
              conceptos.add(Concepto.fromJson(conceptoData));
            }
          }
        }
      }
    } catch (e) {
      developer.log('Error parsing conceptos: ${e.toString()}', error: e);
      // Imprimir el objeto CFDI para entender mejor su estructura
      developer.log(
          'CFDI structure: ${cfdi.toString().substring(0, min(1000, cfdi.toString().length))}');
    }

    developer.log('Found ${conceptos.length} conceptos');
    return conceptos;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'ClaveProdServ': claveProdServ,
      'NoIdentificacion': noIdentificacion,
      'Cantidad': cantidad.toString(), // Convert int to String
      'ClaveUnidad': claveUnidad,
      'Unidad': unidad,
      'Descripcion': descripcion,
      'ValorUnitario': valorUnitario,
      'Importe': importe,
      'ObjetoImp': objetoImp,
    };

    if (impuestos.isNotEmpty || traslados.isNotEmpty) {
      data['Impuestos'] = {};

      if (traslados.isNotEmpty) {
        data['Impuestos']['Traslados'] = {
          'Traslado': traslados.map((t) => t.toJson()).toList()
        };
      }

      if (impuestos.isNotEmpty) {
        final retenciones = impuestos.where((imp) => !imp.esTraslado).toList();
        if (retenciones.isNotEmpty) {
          data['Impuestos']['Retenciones'] = {
            'Retencion': retenciones.map((r) => r.toJson()).toList()
          };
        }
      }
    }

    return data;
  }
}

// Helper min function
int min(int a, int b) => a < b ? a : b;
