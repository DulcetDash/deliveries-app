import 'dart:convert';

import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Helpers/SuperHttp.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../Providers/HomeProvider.dart';

class WalletEntry extends StatefulWidget {
  const WalletEntry({super.key});

  @override
  State<WalletEntry> createState() => _WalletEntryState();
}

class _WalletEntryState extends State<WalletEntry> {
  Future<void> _getWalletData(BuildContext context) async {
    try {
      SuperHttp superHttp = SuperHttp();

      Uri mainUrl = Uri.parse(Uri.encodeFull(
          '${context.read<HomeProvider>().bridge}/wallet/balance'));

      final response = await superHttp.get(
        mainUrl,
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        if (responseData['status'] == 'success') {
          print(responseData);
          context
              .read<HomeProvider>()
              .updateWalletData(data: responseData['data']);
        }
      } else {
        // Handle server error
        context.read<HomeProvider>().updateWalletData(data: {}, reset: true);
      }
    } catch (error) {
      context.read<HomeProvider>().updateWalletData(data: {}, reset: true);
    }
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  void _onRefresh() async {
    _onLoading();
  }

  void _onLoading() async {
    // monitor network fetch
    await _getWalletData(context);
    _refreshController.loadComplete();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          elevation: 0,
          leading: InkWell(
            onTap: () => Navigator.of(context).popAndPushNamed('/home'),
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: AppTheme().getArrowBackSize(),
            ),
          ),
          title: Text(
            'Wallet',
            style: TextStyle(
                fontFamily: 'MoveBold',
                color: Colors.black,
                fontSize: AppTheme().getHeaderPagesTitleSize()),
          ),
        ),
        backgroundColor: AppTheme().getPrimaryColor(),
        body: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: Column(
            children: [
              const HeaderPartWalletEntry(),
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 3,
                              blurRadius: 6)
                        ],
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(35),
                            topRight: Radius.circular(35))),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 30),
                      child: WalletEntryBottomPart(),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//Header part of the wallet entry
class HeaderPartWalletEntry extends StatelessWidget {
  const HeaderPartWalletEntry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> userData = context.watch<HomeProvider>().userData;
    Map<String, dynamic> walletData = context.watch<HomeProvider>().walletData;

    return Container(
      height: 250,
      color: AppTheme().getPrimaryColor(),
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 4,
                              blurRadius: 8)
                        ]),
                    child: CircleAvatar(
                      backgroundColor: Colors.black,
                      backgroundImage: NetworkImage(
                        userData['profile_picture'],
                      ),
                      child: null,
                      radius: 40,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('N\$ ',
                          style: TextStyle(
                              fontFamily: 'MoveBold',
                              fontSize: 24,
                              color: Colors.white)),
                      Text('${walletData['balance'] ?? 0}',
                          style: TextStyle(
                              fontFamily: 'MoveBold',
                              fontSize: 48,
                              color: Colors.white)),
                    ],
                  )),
                  Container(
                      child: Text('Your balance',
                          style: TextStyle(
                              fontSize: 17, color: Colors.grey.shade100))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

//Bottom part of the wallet entry
class WalletEntryBottomPart extends StatelessWidget {
  const WalletEntryBottomPart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/WalletTopupEntry');
            },
            horizontalTitleGap: 5,
            contentPadding: const EdgeInsets.only(left: 0),
            leading: Container(
                child: const Icon(
              Icons.credit_card,
              color: Colors.black,
              size: 35,
            )),
            title: const Text('Top-up',
                style: TextStyle(fontFamily: 'MoveTextBold', fontSize: 20)),
            subtitle: const Text('Safely add money to your wallet.'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 18,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const LastTransactionSection()
        ],
      ),
    );
  }
}

//Last transaction part
class LastTransactionSection extends StatelessWidget {
  const LastTransactionSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> walletData = context.watch<HomeProvider>().walletData;

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    'Latest transactions',
                    style: TextStyle(fontSize: 19, color: Colors.grey.shade700),
                  )),
                  walletData['transactionHistory'].length <= 0
                      ? const SizedBox.shrink()
                      : Text('View all',
                          style: TextStyle(
                              fontSize: 17,
                              fontFamily: 'MoveTextMedium',
                              color: AppTheme().getPrimaryColor()))
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              child: walletData['transactionHistory'].length <= 0
                  ? Container(
                      child: Column(
                        children: [
                          const Divider(
                            height: 50,
                            color: Colors.white,
                          ),
                          Icon(
                            Icons.compare_arrows_rounded,
                            size: 45,
                            color: Colors.grey.shade400,
                          ),
                          Text('No transactions yet.',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 15))
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemBuilder: (context, index) {
                        var transaction =
                            walletData['transactionHistory'][index];
                        Map<String, dynamic> transactionFormatted =
                            getAmountStandards(transaction: transaction);

                        return Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 0.5, color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(3)),
                          child: ListTile(
                            horizontalTitleGap: 0,
                            contentPadding: const EdgeInsets.only(
                                left: 10, right: 10, top: 5, bottom: 5),
                            leading: const Icon(Icons.calendar_today),
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(transactionFormatted['title'],
                                        style: const TextStyle(
                                            fontFamily: 'MoveTextMedium',
                                            fontSize: 17))),
                                Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        transactionFormatted['payment_mode'],
                                        style: TextStyle(
                                            fontFamily: 'MoveText',
                                            color: AppTheme()
                                                .getSecondaryColor())))
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(transactionFormatted['date']),
                            ),
                            trailing: Text(
                              transactionFormatted['amountString'],
                              style: TextStyle(
                                  fontFamily: 'MoveMedium',
                                  fontSize: 22,
                                  color: transactionFormatted['amountColor']),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const Divider(color: Colors.white),
                      itemCount:
                          walletData['transactionHistory'].sublist(0, 3).length,
                    ),
            )
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> getAmountStandards(
      {required Map<String, dynamic> transaction}) {
    switch (transaction['description']) {
      case 'Top-up':
        return {
          'title': 'Top-up',
          'payment_mode': 'Cashless',
          'amountString': '+N\$${transaction['amount']}',
          'amountColor': AppTheme().getSecondaryColor(),
          'date': '12-05-2021 at 13:00'
        };
      case 'Grocery delivery':
        return {
          'title': 'Paid for grocery delivery',
          'payment_mode': 'Cashless',
          'amountString': '-N\$${transaction['amount']}',
          'amountColor': AppTheme().getErrorColor(),
          'date': '12-05-2021 at 13:00'
        };
      case 'Package delivery':
        return {
          'title': 'Paid for package delivery',
          'payment_mode': 'Cashless',
          'amountString': '-N\$${transaction['amount']}',
          'amountColor': AppTheme().getErrorColor(),
          'date': '12-05-2021 at 13:00'
        };
      default:
        return {
          'title': 'Transaction',
          'payment_mode': 'Cashless',
          'amountString': '-N\$${transaction['amount']}',
          'amountColor': Colors.grey
        };
    }
  }
}
