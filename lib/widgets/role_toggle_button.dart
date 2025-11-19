import 'package:flutter/material.dart';

class RoleToggleButton extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  const RoleToggleButton({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment<String>(value: 'Mahasiswa', label: Text('Mahasiswa')),
        ButtonSegment<String>(value: 'Dosen', label: Text('Dosen')),
      ],
      selected: {selectedRole},
      onSelectionChanged: (Set<String> newSelection) {
        onRoleChanged(newSelection.first);
      },
      style: ButtonStyle(
        side: WidgetStateProperty.all(BorderSide(color: cs.outline)),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? cs.primaryContainer
              : cs.surface;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? cs.onPrimaryContainer
              : cs.onSurface;
        }),
      ),
    );
  }
}