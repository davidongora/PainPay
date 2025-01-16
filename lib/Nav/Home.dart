// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:pain_pay/Nav/notifications.dart';
import 'package:pain_pay/Nav/payment/pay_bill/profile/profile.dart';
import 'package:pain_pay/services/notification_service.dart';
import 'package:pain_pay/services/pdf_service.dart';
import 'package:pain_pay/shared/Texts.dart';
import 'package:pain_pay/shared/app_bar.dart';
import 'package:pain_pay/shared/buttons.dart';
import 'package:pain_pay/shared/colors.dart';
import 'package:pain_pay/shared/credit_card.dart';
import 'package:pain_pay/shared/form_modal.dart';
import 'package:pain_pay/shared/language.dart';
import 'package:pain_pay/shared/modal.dart';
import 'package:pain_pay/shared/size.dart';
import 'package:pain_pay/wallets/list_wallets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.showcaseEnabled = false});
  final bool showcaseEnabled;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _viewAll = false;
  final int _previewCount = 5;
  int _totalTransactions = 0;
  List<Map<String, dynamic>> wallets = [];
  List<Map<String, dynamic>> transactions = [];
  List<String> walletIds = [];
  bool shownShowCase = false;
  // final String message = 'at'.tr();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final GlobalKey globalKeyOne = GlobalKey();
  final GlobalKey globalKeyTwo = GlobalKey();
  final GlobalKey globalKeyThree = GlobalKey();
  final GlobalKey globalKeyFour = GlobalKey();
  final GlobalKey globalKeyFive = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.showcaseEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) =>
          ShowCaseWidget.of(context).startShowCase([
            globalKeyOne,
            globalKeyTwo,
            globalKeyThree,
            globalKeyFour,
            globalKeyFive
          ]));
    }

    // WidgetsBinding.instance.addPostFrameCallback((_) =>
    //     ShowCaseWidget.of(context).startShowCase([
    //       globalKeyOne,
    //       globalKeyTwo,
    //       globalKeyThree,
    //       globalKeyFour,
    //       globalKeyFive
    //     ]));
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    initializeNotifications();
    loadWallets();
    fetchTransactions();
    getGreeting();
    checkAndShowShowCase();
    // _initializeRemoteConfig();
    // print(message);
  }

  Future<void> checkAndShowShowCase() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('showcase_shown') ?? false;

    if (!isFirstLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([
          globalKeyOne,
          globalKeyTwo,
          globalKeyThree,
          globalKeyFour,
          globalKeyFive
        ]);
      });
      prefs.setBool('showcase_shown', true);
    }
  }

  void startShowCase() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowCaseWidget.of(context).startShowCase([
        globalKeyOne,
        globalKeyTwo,
        globalKeyThree,
        globalKeyFour,
        globalKeyFive
      ]);
    });
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
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

      Navigator.pop(context);

      await OpenFile.open(filePath);
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  Future<void> loadWallets() async {
    final fetchedWallets = await fetchWallets();
    walletIds =
        wallets.map((wallet) => wallet['wallet_id'].toString()).toList();
    setState(() {
      wallets = fetchedWallets;
      walletIds =
          wallets.map((wallet) => wallet['wallet_id'].toString()).toList();
    });
  }

  Future<void> fetchTransactions() async {
    try {
      final transactionData = await getTransactions();
      final results = transactionData['results'] as List;

      setState(() {
        transactions = List<Map<String, dynamic>>.from(results);
        _totalTransactions = transactionData['count'] as int? ?? 0;
      });

      await NotificationService().showNotification(
        title: 'Transactions Updated',
        body: 'Successfully loaded ${results.length} transactions',
      );

      // Success notification
      flutterLocalNotificationsPlugin.show(
        0,
        'Transactions Updated',
        'Successfully loaded ${results.length} transactions',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      // print('Error loading transactions: $e');
      await NotificationService().showNotification(
        title: 'Error Loading Transactions',
        body: 'Please check your connection and try again',
        id: 1,
      );

      flutterLocalNotificationsPlugin.show(
        1,
        'Error Loading Transactions',
        'Please check your connection and try again',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }
  }

  Future<void> funIntratransfer(Map<String, dynamic> values) async {
    try {
      await intraTransfer(
          amount: values['amount'],
          id: values['id'],
          wallet_id: values['wallet_id'],
          narrative: values['narrative']);

      await NotificationService().showNotification(
        title: 'Transactions Updated',
        body: 'Successfully tranfered ${values['amount']} transactions',
      );

      // Success notification
      flutterLocalNotificationsPlugin.show(
        0,
        'Transactions Updated',
        'Successfully transfered ${values['amount']} transactions',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('funds transfered successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to transfer funds: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> createWallets(Map<String, dynamic> values) async {
    try {
      setState(() {
        fetchWallets();
      });
      final label = values['label'];
      bool can_disburse = values['can_disburse'] == 'true';

      await createWallet(
        currency: values['currency'],
        wallet_type: values['wallet_type'],
        can_disburse: can_disburse,
        label: values['label'],
      );

      await NotificationService().showNotification(
        title: 'Transactions Updated',
        body: 'wallet  ${values['label']} Successfully created',
      );

      // Success notification
      flutterLocalNotificationsPlugin.show(
        0,
        'Transactions Updated',
        'wallet ${label} created Successfully',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wallet created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create wallet: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> exchangeFunds(Map<String, dynamic> values) async {
    try {
      final Map<String, dynamic> response = await currencyExchange(
          id: values['id'],
          currency: values['currency'],
          amount: values['amount'],
          action: values['action']);

      await NotificationService().showNotification(
        title: 'Transactions Updated',
        body: 'exchanged  ${values['amount']} succesfully',
      );

      // Success notification
      flutterLocalNotificationsPlugin.show(
        0,
        'Transactions Updated',
        'exchanged ${values['amount']} Successfully',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );

      await NotificationService().showNotification(
        title: 'Transactions Updated',
        body: 'exchanged  ${values['amount']} succesfully',
      );

      if (response.containsKey('narrative')) {
        flutterLocalNotificationsPlugin.show(
          0,
          'Transactions Updated',
          'Exchange of ${response['fxe_amount']} ${response['currency']} ${response['narrative']} exchanged Successfully',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
        );

        AppModal.showModal(
          onPressed: () {},
          context: context,
          title: 'Exchange Successful',
          content: '''
Rate: ${response['rate']}
Amount: ${response['fxe_amount']} ${response['currency']}
${response!['narrative']}''',
          messageType: MessageType.success,
        );
      } else {
        AppModal.showModal(
          onPressed: () {},
          context: context,
          title: 'Exchange Information',
          content: '''
Rate: ${response['rate']}
You will receive: ${response['fxe_amount']} ${response['currency']}''',
          messageType: MessageType.info,
        );
      }
    } catch (e) {
      AppModal.showModal(
        onPressed: () {},
        context: context,
        title: 'Exchange Failed',
        content: e.toString(),
        messageType: MessageType.error,
      );
    }
  }

  Future<void> fundWallets(
      BuildContext context, Map<String, dynamic> values) async {
    // print('wallet funding');
    try {
      // Call fundWallet and get the response
      final response = await fundWallet(
        amount: values['amount'],
        phone_number: values['phone_number'],
        wallet_id: values['wallet_id'],
      );

      // print('trying to fund wallet');
      // print(response);

      flutterLocalNotificationsPlugin.show(
        0,
        'Transactions',
        '${response['invoice']['invoice_id']} processed Successfully ',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );

      final transactionState = response['invoice']['state'];

      // Validate response structure
      if (response != null &&
          response.containsKey('invoice') &&
          response['invoice'].containsKey('invoice')) {
        final invoiceId = response['invoice']['invoice_id'];

        // Call checkStatus automatically
        final statusResponse = await checkStatus(invoice_id: invoiceId);

        flutterLocalNotificationsPlugin.show(
          0,
          'Transactions Updated',
          '${response['invoice']} processed Successfully ',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Wallet ${values['wallet_id']} funded successfully! Invoice ID: $invoiceId. Transaction status: $transactionState',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Ensure statusResponse is valid
        if (statusResponse != null &&
            statusResponse.containsKey('invoice') &&
            statusResponse['invoice'].containsKey('state')) {
          final transactionState = statusResponse['invoice']['state'];

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Wallet ${values['wallet_id']} funded successfully! Invoice ID: $invoiceId. Transaction status: $transactionState',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception('Transaction status not found in statusResponse');
        }
      } else {
        throw Exception('Invoice ID not found in the response');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to fund wallet or check status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenSizes(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Home',
        // actions: [LanguageSwitcher()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NormalText(text: getGreeting()),
                          // NormalText(text: 'user'.tr()),
                          NormalText(text: 'Merchant'),
                          // Text('welcome_message'.tr()),
                          // Text('at'.tr()),
                          // Text('user'.tr()),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        // const Icon(
                        //   Icons.notifications_outlined,
                        //   size: 40,
                        // ),
                        // const SizedBox(width: 16),
                        Showcase(
                          key: globalKeyOne,
                          description: 'manage your profile here',
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyProfile()));
                            },
                            child: CircleAvatar(
                              radius: 24,
                              child: Image.asset(
                                'assets/welcomePage.png',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  width: 10,
                ),

                SizedBox(
                  width: 10,
                ),
                Showcase(
                  key: globalKeyTwo,
                  description: 'your wallets ',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: wallets.isEmpty
                            ?
                            // const Center(child: CircularProgressIndicator())
                            Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    height: 180,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 4,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Container(
                                            width: 300,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: wallets.map((wallet) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        child: CreditCard(
                                          cardNumber: wallet['wallet_id'],
                                          // cardExpiry:
                                          //     wallet['updated_at'].split('T')[0],
                                          cardExpiry: wallet['current_balance']
                                              .toString(),
                                          cardHolderName: wallet['label'],
                                          cvv: wallet['currency'],
                                          bankName: wallet['wallet_type'],
                                          frontBackgroundColor: AppColors.theme,
                                          backBackgroundGradient:
                                              LinearGradient(
                                            colors: [
                                              Colors.blue,
                                              Colors.purple
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          showShadow: true,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                //       // Padding to show part of the second card

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      child:
                          _buildActionButton('Exchange', Icons.payments_sharp),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ReusableFormModal(
                              title: 'Forex Exchange',
                              description:
                                  'Move money between wallets of different currencies',
                              buttonText: 'Exchange',
                              fields: {
                                'id': {
                                  'type': 'dropdown',
                                  'options': walletIds, // Use wallet IDs here
                                  'label': 'Select Wallet',
                                },
                                'currency': {
                                  'type': 'dropdown',
                                  'options': ['KES', 'USD', 'EUR', 'GBP'],
                                },
                                'amount': {
                                  'type': 'integer',
                                  'hintText': 'Enter the amount >10',
                                },
                                'action': {
                                  'type': 'dropdown',
                                  'options': ['QUOTE', 'EXCHANGE'],
                                },
                              },
                              onSubmit: (values) {
                                final parsedValues = {
                                  'id': values['id'],
                                  'currency': values['currency'].toString(),
                                  'amount': values['amount'].toString(),
                                  'action': values['action'].toString(),
                                };
                                exchangeFunds(parsedValues);
                                // print('Parsed Exchange Values: $parsedValues');
                              },
                              onButtonAction: () {
                                // print('Exchange button action executed!');
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                    ),

                    GestureDetector(
                      child: _buildActionButton(
                          'Transfer', Icons.move_down_rounded),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ReusableFormModal(
                              title: 'Transfer Funds',
                              description:
                                  'Transfer money between your wallets or accounts',
                              buttonText: 'Transfer',
                              fields: {
                                'ID': {
                                  'type': 'dropdown',
                                  'options': walletIds, // Use wallet IDs here
                                  'label': 'Source Wallet',
                                },
                                'Wallet ID': {
                                  'type': 'dropdown',
                                  'options': walletIds, // Use wallet IDs here
                                  'label': 'Destination Wallet',
                                },
                                'Amount': {
                                  'type': 'integer',
                                  'hintText': 'Enter the amount >10',
                                },
                                'Narrative': {
                                  'type': 'string',
                                  'hintText': 'purpose/description/message',
                                },
                              },
                              onSubmit: (values) {
                                // print('Transfer Values: $values');
                              },
                            );
                          },
                        );
                      },
                    ),

                    GestureDetector(
                      child: _buildActionButton('Fund', Icons.money_outlined),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ReusableFormModal(
                              title: 'Fund wallet',
                              description:
                                  'Fill in the details to deposit money to wallet',
                              buttonText: 'Fund',
                              fields: {
                                'wallet_id': {
                                  'type': 'dropdown',
                                  'options': walletIds,
                                },
                                'phone_number': {
                                  'type': 'integer',
                                  'hintText': '254700000000 / 2541000000000',
                                },
                                'amount': {
                                  'type': 'integer',
                                  'hintText': 'Enter the deposit amount >10',
                                },
                              },
                              onSubmit: (values) async {
                                // print('funding initiated');
                                // print('$values');
                                setState(() {
                                  fetchWallets();
                                });
                                await fundWallets(context,
                                    values); // Pass context to fundWallets
                              },
                              onButtonAction: () {
                                fetchWallets();
                                fetchTransactions();
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                    ),
// Then modify your ReusableFormModal implementation to use this method:
                    GestureDetector(
                      child: _buildActionButton('New', Icons.add),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ReusableFormModal(
                              title: 'Create a New Wallet',
                              description:
                                  'Fill in the details to create a new wallet',
                              buttonText: 'Create',
                              fields: {
                                'currency': {
                                  'type': 'dropdown',
                                  'options': ['KES', 'USD', 'EUR', 'GBP'],
                                },
                                'wallet_type': {
                                  'type': 'dropdown',
                                  'options': ['SETTLEMENT', 'WORKING'],
                                },
                                'can_disburse': {
                                  'type': 'dropdown',
                                  'options': ['true', 'false'],
                                },
                                'label': {
                                  'type': 'string',
                                  'hintText': 'Savings',
                                },
                              },
                              onSubmit: (values) async {
                                // Navigator.pop(context);
                                // print('$values');
                                setState(() {
                                  fetchWallets();
                                });
                                await createWallets(
                                    values); // Call the createWallet method
                              },
                              onButtonAction: () {
                                fetchWallets();
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                // Transactions header
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                    Showcase(
                      key: globalKeyThree,
                      description: 'Download transaction statement',
                      child: Row(
                        children: [
                          const SubTitle(text: 'Transactions'),
                          GestureDetector(
                            child: Icon(Icons.download),
                            onTap: () async {
                              try {
                                // Show loading indicator
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  },
                                );

                                await fetchTransactions();
                                await generatePDF();

                                // Hide loading indicator
                                Navigator.pop(context);
                              } catch (e) {
                                // Hide loading indicator
                                Navigator.pop(context);
                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Error generating PDF: $e')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Showcase(
                      key: globalKeyFour,
                      description: 'View All transactions',
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _viewAll = !_viewAll;
                          });
                        },
                        child: NormalText(
                          text: _viewAll ? 'Show Less' : 'View All',
                        ),
                      ),
                    )
                  ],
                ),
                transactions.isEmpty
                    ?
                    // Center(
                    // child: Padding(
                    //   padding: EdgeInsets.only(top: 10),
                    //   child: CircularProgressIndicator(),

                    Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 16,
                                              width: 16,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Container(
                                        height: 16,
                                        width: 60,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                );
                              }),
                        ),
                      )

                    // ),

                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            _viewAll ? _totalTransactions : _previewCount,
                        itemBuilder: (context, index) {
                          if (index >= transactions.length) return null;
                          final transaction = transactions[index];
                          final isPositiveValue = transaction['value'] > 0;
                          final formattedDate =
                              DateTime.parse(transaction['created_at'])
                                  .toLocal()
                                  .toString()
                                  .split('.')[0];

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                  horizontal: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isPositiveValue
                                          ? Icons.add_circle
                                          : Icons.remove_circle,
                                      size: 30,
                                      color: isPositiveValue
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            transaction['narrative'] ??
                                                'Unknown Transaction',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow
                                                .ellipsis, // Add ellipsis for long text
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            formattedDate,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Amount - Now properly aligned
                                    Text(
                                      '${transaction['currency']} ${transaction['value'].abs()}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isPositiveValue
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                            ],
                          );
                        },
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          child: Icon(
            icon,
            color: Colors.white,
          ),
          backgroundColor: Color(0xff13683c),
        ),
        NormalText(text: text),
      ],
    );
  }
}

// Reusable function to open the modal
void _openModal(
  BuildContext context,
  String title,
  String description,
  String buttonText,
  Map<String, dynamic> fields,
) {
  showDialog(
    context: context,
    builder: (context) => ReusableFormModal(
      title: title,
      description: description,
      fields: fields,
      buttonText: buttonText,
      onSubmit: (values) {
        // print('Form submitted with values: $values');
      },
    ),
  );
}

Widget _buildActionButton(String text, IconData icon) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 18,
        // color: Colors.white,
      ),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontSize: 16)),
    ],
  );
}
