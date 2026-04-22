import 'package:flutter/material.dart';

class EnumOption<T> {
  const EnumOption({required this.value, required this.label});

  final T value;
  final String label;
}

class EnumRow<T> extends StatelessWidget {
  const EnumRow({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<EnumOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options
                .map(
                  (option) => ChoiceChip(
                    label: Text(option.label),
                    selected: option.value == value,
                    onSelected: (_) => onChanged(option.value),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
