import 'package:flutter/material.dart';
import 'widget/Custom_bottom_navigation_bar.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});
  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  int _selectedIndex = 2;

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
          child: Text('나에게 맞는 운동 찾기 feat. AI',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      body: Center(
        child: Text('Hello, World!'),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
