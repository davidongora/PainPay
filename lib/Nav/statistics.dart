import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pain_pay/Nav/pie.dart';
import 'package:pain_pay/services/pdf_service.dart';
import 'package:pain_pay/shared/Texts.dart';
import 'package:pain_pay/shared/app_bar.dart';
import 'package:pain_pay/shared/buttons.dart';
import 'package:pain_pay/shared/campaign_banner.dart';
import 'package:pain_pay/shared/colors.dart';
import 'package:pain_pay/shared/credit_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pain_pay/wallets/list_wallets.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  bool _viewAll = false;
  // static const int _previewCount = 3;
  // static const int _totalTransactions = 10;

  final int _previewCount = 5;
  int _totalTransactions = 0;
  List<Map<String, dynamic>> wallets = [];
  List<Map<String, dynamic>> transactions = [];
  List<String> walletIds = []; // Add this to store wallet IDs
  bool showBanner = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
    _initializeRemoteConfig();
  }

  final List<Color> colors = const [
    Color(0xff0293ee),
    Color(0xfff8b250),
    Color(0xff845bef),
    Color(0xff13d38e),
  ];

  Future<void> fetchTransactions() async {
    try {
      final transactionData = await getTransactions();
      final results = transactionData['results'] as List;

      setState(() {
        transactions = List<Map<String, dynamic>>.from(results);
        _totalTransactions = transactionData['count'] as int? ?? 0;
      });
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }

  Future<void> generatePDF() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final pdfService = PDFService();
      final filePath = await pdfService.generateTransactionPDF(
        transactions: transactions,
        title: 'Transaction Report',
      );

      // Hide loading indicator
      Navigator.pop(context);

      // Open the PDF
      await OpenFile.open(filePath);
    } catch (e) {
      // Hide loading indicator if showing
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  Future<void> _initializeRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      print('Fetching remote configuration...');

      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 1), // For testing
      ));

      // Set default values
      remoteConfig.setDefaults({'enable_banner': false});

      await remoteConfig.fetchAndActivate();

      final enablebanned = remoteConfig.getBool('enable_banner');
      print('enable_banner: $enablebanned');

      if (enablebanned) {
        print('Sending auth code as enabled in remote config');
        setState(() {
          showBanner = true;
        });
      } else {
        print('Auth code sending is disabled via remote config');
      }
    } catch (e) {
      print('Error fetching remote config: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Statistics',
      ),
      body: SafeArea(
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(7.0),
            child: Column(
              children: [
                // in this section

                ExpensesPieChart(
                  transactions: transactions,
                ),
                // Container section
                Spacer(),
                const SizedBox(height: 40),
                AppButton(
                  text: 'View Report',
                  onPressed: () {
                    generatePDF();
                  },
                ),

                // Banner section
                if (showBanner)
                  Row(
                    children: const [
                      Expanded(
                        child: CampaignBanner(),
                      ),
                    ],
                  ),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   children: [
                //     AppButton(
                //       text: 'generate Report',
                //       onPressed: () {},
                //     ),
                //     // Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                //     // Container(
                //     //   height: 80,
                //     //   width: 180,
                //     //   decoration: BoxDecoration(
                //     //     color: AppColors.theme,
                //     //   ),
                //     //   child: Row(
                //     //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //     //     crossAxisAlignment: CrossAxisAlignment.center,
                //     //     children: [
                //     //       AppButton(
                //     //         text: 'generate Report',
                //     //         onPressed: () {},
                //     //       ),
                //     //     //   Column(
                //     //     //     mainAxisAlignment: MainAxisAlignment.center,
                //     //     //     crossAxisAlignment: CrossAxisAlignment.center,
                //     //     //     children: [
                //     //     //       // const Icon(Icons.picture_as_pdf_outlined),
                //     //     //       // Text('30000',
                //     //     //       //     style: TextStyle(color: Colors.white)),
                //     //     //       AppButton(
                //     //     //         text: 'generate Report',
                //     //     //         onPressed: () {},
                //     //     //       )
                //     //     //       // SizedBox(height: 8),
                //     //     //       // Text('Transactions report',
                //     //     //       //     style: TextStyle(color: Colors.white)),
                //     //     //     ],
                //     //     //   ),
                //     //     ],
                //     //   ),
                //     // ),
                //     // //   Spacer(),
                //     //   Container(
                //     //     height: 80,
                //     //     width: 180,
                //     //     decoration: BoxDecoration(
                //     //       color: AppColors.theme,
                //     //     ),
                //     //     // child: Row(
                //     //     //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //     //     //   crossAxisAlignment: CrossAxisAlignment.center,
                //     //     //   children: [
                //     //     //     Column(
                //     //     //       mainAxisAlignment: MainAxisAlignment.center,
                //     //     //       crossAxisAlignment: CrossAxisAlignment.center,
                //     //     //       children: const [
                //     //     //         Text('2000',
                //     //     //             style: TextStyle(color: Colors.white)),
                //     //     //         SizedBox(height: 8),
                //     //     //         Text('income',
                //     //     //             style: TextStyle(color: Colors.white)),
                //     //     //       ],
                //     //     //     ),
                //     //     //   ],
                //     //     // ),
                //     //   ),
                // ],
                // ),

                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          child: Icon(icon),
        ),
        NormalText(text: text),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, double percentage) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label\n$percentage%',
            style: const TextStyle(
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
