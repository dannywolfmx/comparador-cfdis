import 'dart:convert';
import 'dart:io';
import 'package:comparador_cfdis/models/filter_template.dart';
import 'package:comparador_cfdis/models/filter.dart';
import 'package:comparador_cfdis/models/filter_forma_pago.dart';
import 'package:comparador_cfdis/models/filter_metodo_pago.dart';
import 'package:comparador_cfdis/models/filter_tipo_comprobante.dart';
import 'package:comparador_cfdis/models/filter_uso_de_cfdi.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class FilterTemplateService {
  static const String _fileName = 'filter_templates.json';
  static const String _predefineTemplatesKey = 'predefined_templates';
  static const String _customTemplatesKey = 'custom_templates';

  final Uuid _uuid = const Uuid();

  /// Obtiene el archivo donde se guardan las plantillas
  Future<File> _getTemplateFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  /// Carga todas las plantillas (predefinidas + personalizadas)
  Future<List<FilterTemplate>> loadTemplates() async {
    try {
      final file = await _getTemplateFile();
      if (!await file.exists()) {
        return _createPredefinedTemplates();
      }

      final jsonString = await file.readAsString();
      final Map<String, dynamic> data = json.decode(jsonString);

      final List<FilterTemplate> templates = [];

      // Cargar plantillas predefinidas
      if (data.containsKey(_predefineTemplatesKey)) {
        final predefinedList = data[_predefineTemplatesKey] as List;
        for (final templateData in predefinedList) {
          templates.add(_parseTemplateFromJson(templateData));
        }
      }

      // Cargar plantillas personalizadas
      if (data.containsKey(_customTemplatesKey)) {
        final customList = data[_customTemplatesKey] as List;
        for (final templateData in customList) {
          templates.add(_parseTemplateFromJson(templateData));
        }
      }

      return templates.isNotEmpty ? templates : _createPredefinedTemplates();
    } catch (e) {
      // Logger para debugging
      return _createPredefinedTemplates();
    }
  }

  /// Guarda una plantilla personalizada
  Future<void> saveTemplate(FilterTemplate template) async {
    try {
      final allTemplates = await loadTemplates();
      final existingIndex = allTemplates.indexWhere((t) => t.id == template.id);

      if (existingIndex >= 0) {
        allTemplates[existingIndex] =
            template.copyWith(updatedAt: DateTime.now());
      } else {
        allTemplates.add(template);
      }

      await _saveAllTemplates(allTemplates);
    } catch (e) {
      throw Exception('No se pudo guardar la plantilla');
    }
  }

  /// Elimina una plantilla
  Future<void> deleteTemplate(String templateId) async {
    try {
      final allTemplates = await loadTemplates();
      allTemplates.removeWhere((t) => t.id == templateId);
      await _saveAllTemplates(allTemplates);
    } catch (e) {
      throw Exception('No se pudo eliminar la plantilla');
    }
  }

  /// Actualiza el estado activo de una plantilla
  Future<void> toggleTemplate(String templateId, bool isActive) async {
    try {
      final allTemplates = await loadTemplates();
      final index = allTemplates.indexWhere((t) => t.id == templateId);

      if (index >= 0) {
        allTemplates[index] = allTemplates[index].copyWith(
          isActive: isActive,
          updatedAt: DateTime.now(),
        );
        await _saveAllTemplates(allTemplates);
      }
    } catch (e) {
      throw Exception('No se pudo actualizar la plantilla');
    }
  }

  /// Crea una nueva plantilla
  FilterTemplate createTemplate({
    required String name,
    required String description,
    required Set<FilterOption> filters,
    Color color = Colors.blue,
  }) {
    return FilterTemplate(
      id: _uuid.v4(),
      name: name,
      description: description,
      filters: filters,
      color: color,
      isActive: false,
    );
  }

  /// Guarda todas las plantillas
  Future<void> _saveAllTemplates(List<FilterTemplate> templates) async {
    try {
      final file = await _getTemplateFile();

      // Separar plantillas predefinidas y personalizadas
      final predefinedTemplates =
          templates.where((t) => _isPredefinedTemplate(t.id)).toList();
      final customTemplates =
          templates.where((t) => !_isPredefinedTemplate(t.id)).toList();

      final Map<String, dynamic> data = {
        _predefineTemplatesKey:
            predefinedTemplates.map((t) => _templateToJson(t)).toList(),
        _customTemplatesKey:
            customTemplates.map((t) => _templateToJson(t)).toList(),
      };

      await file.writeAsString(json.encode(data));
    } catch (e) {
      throw Exception('No se pudieron guardar las plantillas');
    }
  }

  /// Convierte una plantilla a JSON
  Map<String, dynamic> _templateToJson(FilterTemplate template) {
    return {
      'id': template.id,
      'name': template.name,
      'description': template.description,
      'filters': template.filters
          .map((f) => {
                'id': f.id,
                'nombre': f.nombre,
                'type': f.runtimeType.toString(),
              })
          .toList(),
      'isActive': template.isActive,
      'createdAt': template.createdAt.toIso8601String(),
      'updatedAt': template.updatedAt.toIso8601String(),
      'color': template.color.value,
    };
  }

  /// Parsea una plantilla desde JSON
  FilterTemplate _parseTemplateFromJson(Map<String, dynamic> json) {
    final Set<FilterOption> filters = {};

    if (json['filters'] != null) {
      final filtersList = json['filters'] as List;
      for (final filterData in filtersList) {
        final filterOption = _createFilterFromData(filterData);
        if (filterOption != null) {
          filters.add(filterOption);
        }
      }
    }

    return FilterTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      filters: filters,
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      color: Color(json['color'] ?? Colors.blue.value),
    );
  }

  /// Crea un filtro desde los datos JSON
  FilterOption? _createFilterFromData(Map<String, dynamic> data) {
    final String type = data['type'] ?? '';
    final String id = data['id'] ?? '';
    final String nombre = data['nombre'] ?? '';

    switch (type) {
      case 'FormaPago':
        return FormaPago(id, nombre);
      case 'MetodoPago':
        return MetodoPago(id, nombre);
      case 'TipoComprobante':
        return TipoComprobante(id, nombre);
      case 'UsoDeCFDI':
        return UsoDeCFDI(id, nombre);
      default:
        return null;
    }
  }

  /// Verifica si una plantilla es predefinida
  bool _isPredefinedTemplate(String templateId) {
    return templateId.startsWith('predefined_');
  }

  /// Crea plantillas predefinidas
  List<FilterTemplate> _createPredefinedTemplates() {
    return [
      FilterTemplate(
        id: 'predefined_facturas_recibidas',
        name: 'Facturas Recibidas',
        description: 'Filtro para facturas de ingreso recibidas',
        filters: {
          TipoComprobante('I', 'Ingreso'),
        },
        color: Colors.green,
      ),
      FilterTemplate(
        id: 'predefined_facturas_emitidas',
        name: 'Facturas Emitidas',
        description: 'Filtro para facturas de egreso emitidas',
        filters: {
          TipoComprobante('E', 'Egreso'),
        },
        color: Colors.red,
      ),
      FilterTemplate(
        id: 'predefined_gastos_generales',
        name: 'Gastos Generales',
        description: 'Filtro para gastos generales de la empresa',
        filters: {
          UsoDeCFDI('G03', 'Gastos en general'),
        },
        color: Colors.orange,
      ),
      FilterTemplate(
        id: 'predefined_nomina',
        name: 'Nómina',
        description: 'Filtro para comprobantes de nómina',
        filters: {
          TipoComprobante('N', 'Nómina'),
        },
        color: Colors.purple,
      ),
      FilterTemplate(
        id: 'predefined_pagos_efectivo',
        name: 'Pagos en Efectivo',
        description: 'Filtro para pagos realizados en efectivo',
        filters: {
          FormaPago('01', 'Efectivo'),
        },
        color: Colors.brown,
      ),
    ];
  }
}
