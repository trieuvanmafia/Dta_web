import 'package:flutter/material.dart';

import '../common/colors.dart';

class MenuBar extends StatelessWidget {
  const MenuBar(this.onTap,
      {required List<String> listTitle, required int index, Key? key})
      : _index = index,
        _listTitle = listTitle,
        super(key: key);

  final List<String> _listTitle;
  final int _index;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: _listTitle.asMap().entries.map((e) {
        String title = e.value;
        int index = e.key;
        return Row(
          children: [
            GestureDetector(
              child: Text(
                title,
                style: TextStyle(
                    color: _index == index ? textSelectColor : Colors.black),
              ),
              onTap: () {
                onTap(index);
              },
            ),
            index == _listTitle.length - 1
                ? const SizedBox()
                : const Text(' | ')
          ],
        );
      }).toList(),
    );
  }
}
