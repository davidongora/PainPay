import 'package:flutter/material.dart';
import 'package:pain_pay/Nav/Home.dart';
import 'package:pain_pay/Nav/pay.dart';
import 'package:pain_pay/Nav/payment/pay_bill/profile/support.dart';
import 'package:pain_pay/Onboarding/privacy_policy.dart';
import 'package:pain_pay/Onboarding/welcome.dart';
import 'package:pain_pay/shared/Texts.dart';
import 'package:pain_pay/shared/app_bar.dart';
import 'package:pain_pay/shared/Theme/theme_notifier.dart';
import 'package:pain_pay/shared/bottom_nav.dart';
import 'package:pain_pay/shared/showcase.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  // final GlobalKey _one = GlobalKey();
  // final GlobalKey _two = GlobalKey();

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => startShowCase());
  }

  // void _startShowcase() {
  //   final showcaseManager =
  //       Provider.of<ShowcaseManager>(context, listen: false);
  //   if (!showcaseManager.hasShownShowcase) {
  //     ShowCaseWidget.of(context).startShowCase([_one, _two]);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/welcomePage.png'),
            ),
            const SizedBox(height: 10),
            Text(
              'Merchant Profile',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '023030330033',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.verified_user),
                    title: Text('KYC Verification', style: textTheme.bodyLarge),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'viewing of this page is disabled by the developer')));
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.brightness_6),
                    title: Text('Theme', style: textTheme.bodyLarge),
                    trailing: Switch(
                      value: themeNotifier.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        themeNotifier.setTheme(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.article),
                    title:
                        Text('Terms & conditions', style: textTheme.bodyLarge),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivacyPolicy()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.support_agent),
                    title: Text('Support', style: textTheme.bodyLarge),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SupportPage()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.help),
                    title: Text('Tour App', style: textTheme.bodyLarge),
                    onTap: () {
                      setState(() {
                      });
                      final showcaseManager =
                          Provider.of<ShowcaseManager>(context, listen: false);
                      showcaseManager.resetShowcase();
                      // ShowCaseWidget.of(context).startShowCase([globalKeyOne]);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MainNavigation(showcaseEnabled: true),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout', style: textTheme.bodyLarge),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Welcome()),
                      );
                    },
                  ),
                  const Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
