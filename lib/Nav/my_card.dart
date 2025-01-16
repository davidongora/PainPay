import 'package:flutter/material.dart';
import 'package:pain_pay/shared/app_bar.dart';
import 'package:pain_pay/shared/colors.dart';
import 'package:pain_pay/shared/credit_card.dart';
import 'package:pain_pay/wallets/list_wallets.dart';

class MyCard extends StatefulWidget {
  MyCard({super.key});

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  List<Map<String, dynamic>> wallets = [];
  bool isCardView = true; // State to toggle between views

  Future<void> loadWallets() async {
    final fetchedWallets = await fetchWallets();

    setState(() {
      wallets = fetchedWallets;
    });
  }

  @override
  void initState() {
    super.initState();
    loadWallets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Wallets',
        actions: [
          IconButton(
            icon: Icon(isCardView ? Icons.list : Icons.credit_card),
            onPressed: () {
              setState(() {
                isCardView = !isCardView; // Toggle view
              });
            },
          ),
        ],
      ),
      body: wallets.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : isCardView
              ? _buildCardView(context)
              : _buildListView(context),
    );
  }

  Widget _buildCardView(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      itemCount: wallets.length,
      itemBuilder: (context, index) {
        final wallet = wallets[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: CreditCard(
              cardNumber: wallet['wallet_id'],
              cardExpiry: wallet['current_balance'].toString(),
              cardHolderName: wallet['label'],
              cvv: wallet['currency'],
              bankName: wallet['wallet_type'],
              frontBackgroundColor: AppColors.theme,
              backBackgroundGradient: const LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              showShadow: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context) {
    return ListView.builder(
      itemCount: wallets.length,
      itemBuilder: (context, index) {
        final wallet = wallets[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            title: Text(wallet['label']),
            subtitle: Text(
                'Balance: ${wallet['current_balance']} ${wallet['currency']}'),
            trailing: Text(wallet['wallet_type']),
          ),
        );
      },
    );
  }
}
