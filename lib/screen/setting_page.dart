import 'package:flutter/material.dart';
import 'widget/Custom_bottom_navigation_bar.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int _selectedIndex = 4;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      return;
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
          child: Text('설정', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.refresh),
            title: Text('캐시 삭제'),
            onTap: () {
              // Add your cache clearing logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('캐시가 초기화되었습니다.')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.code),
            title: Text('오픈소스 라이선스'),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'HealthApp',
                applicationVersion: '1.0.0',
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help & Support'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Help & Support'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.email),
                          title: Text('Email: esse3134@gmail.com'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
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
