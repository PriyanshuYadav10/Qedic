import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:qedic/utility/HexColor.dart';

import 'attendance/AttendanceAcitivity.dart';
import 'Home.dart';
import 'expenses/Expenses.dart';
import 'LoginActivity.dart';
import 'Menu.dart';
import 'visit/VisitList.dart';


class HomeActivity extends StatefulWidget {
  const HomeActivity({Key? key}) : super(key: key);

  @override
  _HomeActivityState createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    Home(),
    AttendanceAcitivity(),
    VisitList(),
    Expenses(),
    Menu(),
  ];

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //     statusBarColor: HexColor(HexColor.white),
    //     statusBarIconBrightness: Brightness.dark));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: HexColor(HexColor.white),
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: HexColor(HexColor.gray_text).withOpacity(1),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 8),
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                style: GnavStyle.oldSchool,
                gap: 2,
                haptic: true,
                // haptic feedback
                activeColor: HexColor(HexColor.white),
                iconSize: 18,
                textSize: 12,
                tabBorderRadius: 10,
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: HexColor(HexColor.primarycolor),
                color: HexColor(HexColor.primarycolor),
                tabs: [
                  GButton(
                    icon: Icons.home_outlined,
                    text: "Home",
                  ),
                  GButton(
                    icon: Icons.alarm_outlined,
                    text:"Attendance",
                  ),
                  GButton(
                    icon: Icons.location_history_outlined,
                    text:"Visit",
                  ),
                  GButton(
                    icon: Icons.monetization_on_outlined,
                    text:"Expenses",
                  ),
                  GButton(
                    icon: Icons.more_outlined,
                    text: "More",

                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
