import 'package:flutter/material.dart';

class FilterDrawer extends StatefulWidget {
  final Function(DateTime?, DateTime?, String?)? onFiltersApplied;

  const FilterDrawer({Key? key, this.onFiltersApplied}) : super(key: key);

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  // Aquí puedes agregar variables de estado para los filtros
  DateTime? startDate;
  DateTime? endDate;
  String? selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Filtros',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          // Sección de filtro por fechas
          ListTile(
            title: const Text('Fecha de Inicio'),
            subtitle: Text(startDate?.toString() ?? 'No seleccionada'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                setState(() {
                  startDate = date;
                });
              }
            },
          ),
          ListTile(
            title: const Text('Fecha de Fin'),
            subtitle: Text(endDate?.toString() ?? 'No seleccionada'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                setState(() {
                  endDate = date;
                });
              }
            },
          ),
          const Divider(),
          // Sección de filtro por estado
          const ListTile(
            title: Text('Estado'),
          ),
          // Ejemplo de opciones de estado
          RadioListTile<String>(
            title: const Text('Todos'),
            value: 'all',
            groupValue: selectedStatus,
            onChanged: (value) {
              setState(() {
                selectedStatus = value;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Vigente'),
            value: 'active',
            groupValue: selectedStatus,
            onChanged: (value) {
              setState(() {
                selectedStatus = value;
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Cancelado'),
            value: 'canceled',
            groupValue: selectedStatus,
            onChanged: (value) {
              setState(() {
                selectedStatus = value;
              });
            },
          ),
          const Divider(),
          // Botón para aplicar filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Aplicar filtros y cerrar el drawer
                if (widget.onFiltersApplied != null) {
                  widget.onFiltersApplied!(startDate, endDate, selectedStatus);
                }
                Navigator.pop(context);
              },
              child: const Text('Aplicar Filtros'),
            ),
          ),
          // Botón para limpiar filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: () {
                setState(() {
                  startDate = null;
                  endDate = null;
                  selectedStatus = null;
                });
              },
              child: const Text('Limpiar Filtros'),
            ),
          ),
        ],
      ),
    );
  }
}
