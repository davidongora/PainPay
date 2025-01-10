import 'package:flutter/material.dart';
import 'package:pain_pay/Authenication/login.dart';
import 'package:pain_pay/Authenication/sign_up.dart';
import 'package:pain_pay/Nav/Home.dart';
import 'package:pain_pay/Nav/my_card.dart';
import 'package:pain_pay/Nav/notifications.dart';
import 'package:pain_pay/Nav/payment/pay_bill/profile/profile.dart';
import 'package:pain_pay/Nav/statistics.dart';
import 'package:pain_pay/shared/colors.dart';

import 'package:shared_preferences/shared_preferences.dart';

class MainNavigation extends StatefulWidget {
  final showcaseEnabled;

  const MainNavigation({Key? key, this.showcaseEnabled = false})
      : super(key: key);

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Set default index to 2, which corresponds to Home
  int _currentIndex = 2;
  bool _showcaseEnabled = false;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MyCard(),
      const Statistics(),
      Home(showcaseEnabled: widget.showcaseEnabled), // Access widget here
      NotificationScreen(),
      const MyProfile(),
    ];
  }

  Future<void> _checkShowcaseStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool showcaseShown = prefs.getBool('showcaseShown') ?? false;

    if (!showcaseShown) {
      // Enable showcase for the first time
      setState(() {
        _showcaseEnabled = true;
      });

      // Set showcase as shown
      await prefs.setBool('showcaseShown', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.credit_card),
              label: 'Cards',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart),
              label: 'Statistics',
            ),
            BottomNavigationBarItem(
              icon: _buildPayButton(),
              label: 'Pay',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_circle),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentIndex == 2 ? AppColors.iconColor : AppColors.disabled,
      ),
      child: Center(
        child: Icon(
          Icons.payment,
          color: _currentIndex == 2 ? Colors.white : Colors.grey[300],
        ),
      ),
    );
  }
}
