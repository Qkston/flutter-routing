import 'package:flutter/material.dart';
import 'tri_state_checkbox.dart';

class GroupCheckBox extends StatefulWidget {
  final List<bool> initialChildStates;

  GroupCheckBox({required this.initialChildStates});

  @override
  _GroupCheckBoxState createState() => _GroupCheckBoxState();
}

class _GroupCheckBoxState extends State<GroupCheckBox> {
  late CheckBoxState groupState;
  late List<bool> childStates;

  @override
  void initState() {
    super.initState();
    childStates = List.from(widget.initialChildStates);
    _updateGroupStateFromChildren();
  }

  void _updateGroupStateFromChildren() {
    if (childStates.every((state) => state)) {
      groupState = CheckBoxState.checked;
    } else if (childStates.every((state) => !state)) {
      groupState = CheckBoxState.unchecked;
    } else {
      groupState = CheckBoxState.indeterminate;
    }
  }

  void _updateChildrenFromGroupState(CheckBoxState newState) {
    setState(() {
      if (newState == CheckBoxState.checked) {
        childStates = List.generate(childStates.length, (index) => true);
      } else if (newState == CheckBoxState.unchecked) {
        childStates = List.generate(childStates.length, (index) => false);
      }
      _updateGroupStateFromChildren();
    });
  }

  void _toggleGroupState() {
    setState(() {
      if (groupState == CheckBoxState.checked) {
        groupState = CheckBoxState.unchecked;
        _updateChildrenFromGroupState(CheckBoxState.unchecked);
      } else if (groupState == CheckBoxState.unchecked ||
          groupState == CheckBoxState.indeterminate) {
        groupState = CheckBoxState.checked;
        _updateChildrenFromGroupState(CheckBoxState.checked);
      }
    });
  }

  void _updateIndividualState(int index, bool value) {
    setState(() {
      childStates[index] = value;
      _updateGroupStateFromChildren();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('Group Control:', style: TextStyle(fontSize: 18)),
            SizedBox(width: 10),
            TriStateCheckBox(
              state: groupState,
              onChanged: (newState) {
                _toggleGroupState();
              },
            ),
          ],
        ),
        SizedBox(height: 20),
        ...List.generate(childStates.length, (index) {
          return Row(
            children: [
              Text('Item ${index + 1}:', style: TextStyle(fontSize: 16)),
              Checkbox(
                value: childStates[index],
                onChanged: (value) {
                  _updateIndividualState(index, value!);
                },
              ),
            ],
          );
        }),
      ],
    );
  }
}
