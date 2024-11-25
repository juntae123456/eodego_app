import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'widget/custom_bottom_navigation_bar.dart';
import 'widget/bottom_sheet_content.dart'; // 새로운 파일 임포트

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(37.7749, -122.4194); // 샌프란시스코 좌표
  int _selectedIndex = 0;
  loc.LocationData? _currentLocation;
  final DraggableScrollableController _scrollableController =
      DraggableScrollableController();

  double _sheetOpacity = 0.00;
  double _buttonOpacity = 1.0; // 버튼의 초기 투명도 설정

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
      }
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
            myLocationButtonEnabled: false, // 기본 위치 버튼 비활성화
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
              child: Container(
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
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 400,
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
