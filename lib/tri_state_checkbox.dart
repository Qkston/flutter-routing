import 'package:flutter/material.dart';

// Перерахування станів для TriStateCheckBox
enum CheckBoxState { checked, unchecked, indeterminate }

class TriStateCheckBox extends StatefulWidget {
  final CheckBoxState? state;
  final ValueChanged<CheckBoxState>? onChanged;

  TriStateCheckBox({
    required this.state,
    required this.onChanged,
  });

  @override
  _TriStateCheckBoxState createState() => _TriStateCheckBoxState();
}

class _TriStateCheckBoxState extends State<TriStateCheckBox> {
  void _toggleState() {
    CheckBoxState? nextState;
    switch (widget.state) {
      case CheckBoxState.unchecked:
        nextState = CheckBoxState.checked;
        break;
      case CheckBoxState.checked:
        nextState = CheckBoxState.indeterminate;
        break;
      case CheckBoxState.indeterminate:
      case null:
        nextState = CheckBoxState.unchecked;
        break;
    }
    if (widget.onChanged != null) {
      widget.onChanged!(nextState);
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (widget.state) {
      case CheckBoxState.checked:
        icon = Icons.check_box;
        break;
      case CheckBoxState.unchecked:
        icon = Icons.check_box_outline_blank;
        break;
      case CheckBoxState.indeterminate:
      case null:
        icon = Icons.indeterminate_check_box;
        break;
    }

    return GestureDetector(
      onTap: _toggleState,
      child: Icon(icon, size: 32.0, color: Colors.blue),
    );
  }
}
