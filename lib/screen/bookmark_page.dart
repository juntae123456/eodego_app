import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:healthapp/screen/widget/admob_service';
import 'database_helper.dart';
import 'widget/custom_bottom_navigation_bar.dart';
import 'widget/detail_sheet.dart'; // detail_sheet.dart 파일을 임포트

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  int _selectedIndex = 3;
  List<Map<String, dynamic>> _bookmarkedMarkers = [];
  String _searchQuery = ''; // 검색 쿼리 변수 추가
  late BannerAd _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBookmarkedMarkers();
    _loadBannerAd();
  }

  Future<void> _loadBookmarkedMarkers() async {
    final markers = await DatabaseHelper().getBookmarkedMarkers();
    setState(() {
      _bookmarkedMarkers = markers;
    });
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId!,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            _isBannerAdLoaded = false;
          });
        },
      ),
    )..load();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      return; // Do nothing if the same tab is tapped
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredMarkers = _bookmarkedMarkers.where((marker) {
      final name = marker['name']?.toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text('즐겨찾기', style: TextStyle(fontWeight: FontWeight.bold)),
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
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18.0)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredMarkers.length,
              itemBuilder: (context, index) {
                final marker = filteredMarkers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: Text(marker['name']),
                    subtitle: Text(marker['road_addr']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await DatabaseHelper().removeBookmark(marker['id']);
                        _loadBookmarkedMarkers(); // Reload the bookmarks
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailSheet(id: marker['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (_isBannerAdLoaded)
            Container(
              alignment: Alignment.center,
              child: AdWidget(ad: _bannerAd),
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
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
