import 'package:flutter/material.dart';

class ColorChoice {
  const ColorChoice({
    required this.label,
    required this.color,
  });

  final String label;
  final Color? color;
}

class ColorRow extends StatelessWidget {
  const ColorRow({
    super.key,
    required this.label,
    required this.value,
    required this.choices,
    required this.onChanged,
  });

  final String label;
  final Color? value;
  final List<ColorChoice> choices;
  final ValueChanged<Color?> onChanged;

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
            children: choices.map((choice) {
              final selected = choice.color == value;
              return InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => onChanged(choice.color),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: choice.color ?? Colors.transparent,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: choice.color == null
                            ? const Center(child: Text('A', style: TextStyle(fontSize: 9)))
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(choice.label),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
