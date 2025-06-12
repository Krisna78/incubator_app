import 'package:flutter/material.dart';
import 'package:incubator_app/pages/beranda.dart';
import 'package:incubator_app/pages/data_telur.dart';

class ButtonNavigation extends StatefulWidget {
  const ButtonNavigation({super.key});

  @override
  State<ButtonNavigation> createState() => _ButtonNavigationState();
}

class _ButtonNavigationState extends State<ButtonNavigation> {
  int _selectedIndex = 0;
  late List<Widget> tabs;
  void initState() {
    super.initState();
    tabs = [
      Beranda(),
      DataTelur(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 27, color: Color(0xFF00A1FF)),
            label: "Beranda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.egg, size: 27, color: Color(0xFF00A1FF)),
            label: "Data Telur",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
