import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'widget/bottom_sheet_content.dart';
import 'widget/custom_bottom_navigation_bar.dart';
import 'database_helper.dart';
import 'widget/detail_sheet.dart'; // detail_sheet.dart 파일을 임포트

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(35.3959361, 128.7384361);
  Set<Marker> _markers = {};
  Set<Marker> _cachedMarkers = {};
  int _selectedIndex = 0;
  loc.LocationData? _currentLocation;
  final DraggableScrollableController _scrollableController =
      DraggableScrollableController();

  double _sheetOpacity = 0.00;
  double _buttonOpacity = 1.0; // 버튼의 초기 투명도 설정
  bool _showFindButton = true; // "현재 화면에서 찾기" 버튼 표시 여부

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadMarkersFromDatabase();
    _scrollableController.addListener(() {
      setState(() {
        _sheetOpacity = _scrollableController.size;
        _buttonOpacity = _scrollableController.size >= 0.3
            ? 0.0
            : 1.0; // 하단 바 상태에 따라 버튼 투명도 설정
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      ));
    }
    _updateVisibleMarkers();
  }

  Future<void> _getCurrentLocation() async {
    loc.Location location = loc.Location();

    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await location.getLocation();
    setState(() {
      if (_currentLocation != null) {
        _initialPosition =
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
        if (_mapController != null) {
          _mapController?.animateCamera(CameraUpdate.newLatLng(
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          ));
        }
      }
    });
  }

  Future<void> _loadMarkersFromDatabase() async {
    final List<Map<String, dynamic>> markers =
        await DatabaseHelper().getMarkers();
    Set<Marker> newMarkers = {};

    for (var marker in markers) {
      LatLng position = LatLng(marker['latitude'], marker['longitude']);
      newMarkers.add(
        Marker(
          markerId: MarkerId(marker['id'].toString()), // 마커의 고유 ID
          position: position, // 위도와 경도를 기반으로 위치 설정
          infoWindow: InfoWindow(
            title: marker['name'], // 마커 이름
            snippet:
                '${marker['road_addr']} - ${marker['main_event_nm']}', // 주소와 종목 추가
            onTap: () {
              // 정보 창을 클릭했을 때 detail_sheet.dart 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailSheet(id: marker['id']),
                ),
              ).then((_) {
                setState(() {
                  _sheetOpacity = 0.0;
                  _buttonOpacity = 1.0;
                  FocusScope.of(context).unfocus();
                  _scrollableController.animateTo(
                    0.1,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                });
              });
            },
          ),
        ),
      );
    }

    setState(() {
      _cachedMarkers = newMarkers;
      _updateVisibleMarkers();
    });
  }

  void _updateVisibleMarkers() async {
    if (_mapController == null) return;

    LatLngBounds visibleRegion = await _mapController!.getVisibleRegion();
    Set<Marker> visibleMarkers = _cachedMarkers.where((marker) {
      return visibleRegion.contains(marker.position);
    }).toSet();

    setState(() {
      _markers = visibleMarkers;
    });
  }

  Future<void> _moveToCurrentLocation() async {
    if (_currentLocation != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      ));
    } else {
      await _getCurrentLocation();
      if (_currentLocation != null) {
        _mapController?.animateCamera(CameraUpdate.newLatLng(
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        ));
      }
    }
  }

  Future<void> _searchLocation() async {
    String address = _searchController.text;
    if (address.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          Location location = locations.first;
          LatLng newPosition = LatLng(location.latitude, location.longitude);
          _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
          setState(() {
            _initialPosition = newPosition;
            _searchController.clear(); // 검색창 지우기
          });
        } else {
          print('No locations found');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      return; // 현재 페이지와 같은 경우 아무 작업도 하지 않음
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _toggleSheet() {
    if (_scrollableController.size <= 0.02) {
      _scrollableController.animateTo(
        0.3,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollableController.animateTo(
        0.02,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _filterMarkers(String mainEventName) async {
    final List<Map<String, dynamic>> markers =
        await DatabaseHelper().getMarkers();
    Set<Marker> filteredMarkers = {};

    for (var marker in markers) {
      if (marker['main_event_nm'] == mainEventName) {
        LatLng position = LatLng(marker['latitude'], marker['longitude']);
        filteredMarkers.add(
          Marker(
            markerId: MarkerId(marker['id'].toString()), // 마커의 고유 ID
            position: position, // 위도와 경도를 기반으로 위치 설정
            infoWindow: InfoWindow(
              title: marker['name'], // 마커 이름
              snippet:
                  '${marker['road_addr']} - ${marker['main_event_nm']}', // 주소와 종목 추가
              onTap: () {
                // 정보 창을 클릭했을 때 detail_sheet.dart 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailSheet(id: marker['id']),
                  ),
                ).then((_) {
                  setState(() {
                    _sheetOpacity = 0.0;
                    _buttonOpacity = 1.0;
                    FocusScope.of(context).unfocus();
                    _scrollableController.animateTo(
                      0.1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  });
                });
              },
            ),
          ),
        );
      }
    }

    setState(() {
      _markers = filteredMarkers;
    });
  }

  void _toggleFindButton(bool show) {
    setState(() {
      _showFindButton = show;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 10,
            ),
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            zoomControlsEnabled: false,
          ),
          AnimatedOpacity(
            opacity: _sheetOpacity,
            duration: const Duration(milliseconds: 100),
            child: IgnorePointer(
              ignoring: _sheetOpacity <= 0.1, // 투명도가 0.02 이하일 때 터치 이벤트 무시
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus(); // 검색창 포커스 해제
                  _toggleSheet();
                },
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: AnimatedOpacity(
              opacity: _buttonOpacity,
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '지역을 검색해주세요.',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _searchLocation,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) => _searchLocation(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_showFindButton)
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // 버튼 배경색을 흰색으로 설정
                        ),
                        onPressed: _updateVisibleMarkers,
                        child: const Text(
                          '현재 화면에서 찾기',
                          style: TextStyle(color: Color(0xFF4A789C)),
                        ))
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _toggleSheet,
            onLongPress: _toggleSheet,
            child: NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                if (notification.extent >= 0.3) {
                  _scrollableController.animateTo(
                    0.3,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                } else if (notification.extent <= 0.02) {
                  _scrollableController.animateTo(
                    0.02,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
                setState(() {
                  _sheetOpacity =
                      notification.extent <= 0.12 ? 0.00 : notification.extent;
                  _buttonOpacity = notification.extent >= 0.3
                      ? 0.0
                      : 1.0; // 하단 바 상태에 따라 버튼 투명도 설정
                });
                return true;
              },
              child: DraggableScrollableSheet(
                controller: _scrollableController,
                initialChildSize: 0.1,
                minChildSize: 0.1,
                maxChildSize: 0.3,
                snap: true,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: BottomSheetContent(
                      scrollController: scrollController,
                      draggableScrollableController: _scrollableController,
                      onFilterMarkers: _filterMarkers, // 필터링 함수 전달
                      onToggleFindButton:
                          _toggleFindButton, // "현재 화면에서 찾기" 버튼 토글 함수 전달
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 200,
            child: AnimatedOpacity(
              opacity: _buttonOpacity,
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.zoom_in),
                          onPressed: _zoomIn,
                        ),
                        IconButton(
                          icon: const Icon(Icons.zoom_out),
                          onPressed: _zoomOut,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    onPressed: _moveToCurrentLocation,
                    child: const Icon(Icons.my_location, color: Colors.black),
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    mini: true,
                  ),
                ],
              ),
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
