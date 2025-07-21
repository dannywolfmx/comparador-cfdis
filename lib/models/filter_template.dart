import 'package:comparador_cfdis/models/filter.dart';
import 'package:flutter/material.dart';

class FilterTemplate {
  final String id;
  final String name;
  final String description;
  final Set<FilterOption> filters;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Color color;

  FilterTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.filters,
    this.isActive = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.color = Colors.blue,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  FilterTemplate copyWith({
    String? id,
    String? name,
    String? description,
    Set<FilterOption>? filters,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Color? color,
  }) {
    return FilterTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      filters: filters ?? this.filters,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'filters': filters.map((f) => {'id': f.id, 'nombre': f.nombre}).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'color': color.toARGB32(),
    };
  }

  static FilterTemplate fromJson(Map<String, dynamic> json) {
    return FilterTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      filters: {}, // Se debe reconstruir desde el contexto específico
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      color: Color(json['color'] ?? Colors.blue.toARGB32()),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterTemplate &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FilterTemplate{id: $id, name: $name, filtersCount: ${filters.length}, isActive: $isActive}';
  }
}
