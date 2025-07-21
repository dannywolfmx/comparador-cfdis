import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';

class FiltroDateRange extends StatefulWidget {
  const FiltroDateRange({super.key});

  @override
  State<FiltroDateRange> createState() => _FiltroDateRangeState();
}

class _FiltroDateRangeState extends State<FiltroDateRange> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDatePicker(
          context: context,
          controller: _startDateController,
          labelText: 'Fecha de inicio',
          onDateSelected: (date) {
            setState(() {
              _startDate = date;
            });
            _applyFilter();
          },
        ),
        const SizedBox(height: 8),
        _buildDatePicker(
          context: context,
          controller: _endDateController,
          labelText: 'Fecha de fin',
          onDateSelected: (date) {
            setState(() {
              _endDate = date;
            });
            _applyFilter();
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
    required ValueChanged<DateTime> onDateSelected,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: const Icon(Icons.calendar_today),
        border: const OutlineInputBorder(),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          controller.text = DateFormat('yyyy-MM-dd').format(date);
          onDateSelected(date);
        }
      },
    );
  }

  void _applyFilter() {
    context.read<CFDIBloc>().add(ApplyDateRangeFilter(_startDate, _endDate));
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}
