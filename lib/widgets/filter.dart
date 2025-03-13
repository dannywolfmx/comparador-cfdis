import 'package:flutter/material.dart';

class FilterColumn extends StatelessWidget {
  const FilterColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 16),
          // Sección de filtro por fechas
          ListTile(
            title: const Text('Fecha de Inicio'),
            subtitle: const Text('No seleccionada'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              //Show date picker
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
            },
          ),
          ListTile(
            title: const Text('Fecha de Fin'),
            subtitle: const Text('No seleccionada'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
            },
          ),
          const Divider(color: Colors.white),
          // Sección de filtro por estatus
          ListTile(
            title: const Text('Estatus'),
            subtitle: const Text('No seleccionado'),
            trailing: const Icon(Icons.filter_list),
            onTap: () async {
              // Aquí puedes agregar la lógica para seleccionar el estatus
            },
          ),
          const Divider(color: Colors.white),
          // Botón para aplicar los filtros
          ElevatedButton(
            onPressed: () {
              // Aquí puedes agregar la lógica para aplicar los filtros
            },
            child: const Text('Aplicar filtros'),
          ),
        ],
      ),
    );
  }
}
