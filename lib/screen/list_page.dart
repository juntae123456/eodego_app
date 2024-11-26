import 'package:flutter/material.dart';
import 'widget/custom_bottom_navigation_bar.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  int _selectedIndex = 1;
  int _selectedButtonIndex = 0;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      return; // 현재 페이지와 같은 경우 아무 작업도 하지 않음
    }
    setState(() {
      _selectedIndex = index;
    });
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
              decoration: InputDecoration(
                hintText: '지역으로 검색하기',
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
                children: [
                  '전체',
                  'Button2',
                  'Button3',
                  'Button4',
                  'Button5',
                  'Button6'
                ].asMap().entries.map((entry) {
                  int idx = entry.key;
                  String button = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 7.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedButtonIndex = idx;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        backgroundColor: _selectedButtonIndex == idx
                            ? Colors.blue[200]
                            : Colors.grey[200],
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
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('ListTile $index',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ListTile Subtitle $index'),
                      Text('Additional Subtitle 1 for $index'),
                      Text('Additional Subtitle 2 for $index'),
                    ],
                  ),
                  onTap: () {
                    print('ListTile $index 클릭됨');
                  },
                );
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
