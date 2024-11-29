import 'package:flutter/material.dart';
import 'widget/custom_bottom_navigation_bar.dart';
import 'database_helper.dart';
import 'widget/detail_sheet.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  int _selectedIndex = 1;
  int _selectedButtonIndex = 0;
  String _selectedButton = '전체'; // 초기에는 "전체" 버튼이 활성화
  List<String> _buttons = ['전체'];
  String _searchQuery = ''; // 검색 쿼리 변수 추가

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

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      return; // 현재 페이지와 같은 경우 아무 작업도 하지 않음
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchMarkers() async {
    if (_searchQuery.isNotEmpty) {
      return await DatabaseHelper().getMarkersByName(_searchQuery);
    } else if (_selectedButton == '전체') {
      return await DatabaseHelper().getMarkers();
    } else {
      return await DatabaseHelper().getMarkersByEvent(_selectedButton);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(
          child:
              Text('스포츠 강좌 리스트', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: '이름으로 검색하기',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18.0)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buttons.map((button) {
                  final isSelected = _selectedButton == button;
                  return Padding(
                    padding: const EdgeInsets.only(right: 7.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedButton = button;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        backgroundColor:
                            isSelected ? Colors.blue[200] : Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        button,
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchMarkers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                } else {
                  final markers = snapshot.data!;
                  return ListView.builder(
                    itemCount: markers.length,
                    itemBuilder: (context, index) {
                      final marker = markers[index];
                      return ListTile(
                        title: Text(marker['name'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(marker['road_addr']),
                            Text(marker['main_event_nm']),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailSheet(id: marker['id']),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
