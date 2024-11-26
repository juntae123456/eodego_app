import 'package:flutter/material.dart';

class BottomSheetContent extends StatefulWidget {
  final ScrollController scrollController;
  final DraggableScrollableController draggableScrollableController;

  const BottomSheetContent({
    required this.scrollController,
    required this.draggableScrollableController,
  });

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  final List<String> _buttons = [
    '버튼 1',
    '버튼 2',
    '버튼 3',
    '버튼 4',
    '버튼 5',
    '버튼 6',
    '버튼 7',
  ];
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    final filteredButtons =
        _buttons.where((button) => button.contains(_searchText)).toList();

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(19.0),
      children: [
        // 검색창
        TextField(
          decoration: InputDecoration(
            hintText: '종목을 입력하세요',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onChanged: (text) {
            setState(() {
              _searchText = text;
            });
          },
          onTap: () {
            widget.draggableScrollableController.animateTo(
              1.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
        ),
        const SizedBox(height: 16.0),
        // 버튼들
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filteredButtons.map((button) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(button),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
