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
        backgroundColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return Colors.black;
          }
          return Colors.white;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.black;
        }),
        side: WidgetStateProperty.all(
          const BorderSide(color: Colors.black, width: 2),
        ),
      ),
    );
  }
}
