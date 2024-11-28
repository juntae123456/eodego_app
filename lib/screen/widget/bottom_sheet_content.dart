import 'package:flutter/material.dart';
import '../database_helper.dart';

class BottomSheetContent extends StatefulWidget {
  final ScrollController scrollController;
  final DraggableScrollableController draggableScrollableController;
  final Function(String) onFilterMarkers; // 필터링 함수 추가
  final Function(bool) onToggleFindButton; // "현재 화면에서 찾기" 버튼 토글 함수 추가

  const BottomSheetContent({
    required this.scrollController,
    required this.draggableScrollableController,
    required this.onFilterMarkers, // 필터링 함수 추가
    required this.onToggleFindButton, // "현재 화면에서 찾기" 버튼 토글 함수 추가
  });

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  List<String> _buttons = [];
  String _searchText = '';
  String _selectedButton = '전체'; // 초기에는 "전체" 버튼이 활성화

  @override
  void initState() {
    super.initState();
    _loadButtons();
  }

  Future<void> _loadButtons() async {
    final buttons = await DatabaseHelper().getUniqueMainEventNames();
    setState(() {
      _buttons = [
        '전체',
        ...buttons.where((button) => button != '기타종목'),
        '기타종목'
      ]; // "기타종목" 버튼을 맨 뒤로 이동
    });
  }

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
            hintText: '종목을 입력하세요.',
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
              final isSelected = _selectedButton == button;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedButton = button;
                    });
                    widget.onFilterMarkers(
                        button == '전체' ? '' : button); // "전체" 버튼이 눌리면 필터링 해제
                    widget.onToggleFindButton(
                        button == '전체'); // "현재 화면에서 찾기" 버튼 토글
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? Colors.blue[200]
                        : Colors.grey[200], // 선택된 버튼 색상 변경
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    button,
                    style: TextStyle(color: Colors.black), // 글자 색을 검정색으로 변경
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
