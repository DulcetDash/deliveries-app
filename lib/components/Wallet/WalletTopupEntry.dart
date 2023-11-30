import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WalletTopupEntry extends StatelessWidget {
  const WalletTopupEntry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.arrow_back,
              size: AppTheme().getArrowBackSize(),
            ),
          ),
          title: Text('Payment settings',
              style: TextStyle(
                  fontFamily: 'MoveBold',
                  fontSize: AppTheme().getHeaderPagesTitleSize())),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.white,
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 15, bottom: 5),
                child: ListTile(
                  leading: Container(
                      alignment: Alignment.center,
                      width: 40,
                      height: 55,
                      child: const Icon(Icons.square,
                          size: 15, color: Colors.black)),
                  horizontalTitleGap: 5,
                  contentPadding: const EdgeInsets.only(left: 0),
                  title: const Text(
                    'Your balance',
                    style: TextStyle(fontFamily: 'MoveRegular', fontSize: 20),
                  ),
                  trailing: Container(
                      alignment: Alignment.centerRight,
                      height: 55,
                      width: MediaQuery.of(context).size.width / 3,
                      child: Text(
                        'N\$${context.watch<HomeProvider>().walletData['balance']}',
                        style: TextStyle(
                            fontFamily: 'MoveBold',
                            fontSize: 22,
                            color: AppTheme().getPrimaryColor()),
                      )),
                ),
              ),
              const Divider(
                thickness: 1,
              ),
              const TopupMethodsPart()
            ],
          ),
        ));
  }
}

//Sending fares options part
class TopupMethodsPart extends StatelessWidget {
  const TopupMethodsPart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25, bottom: 15),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: const Text('Top up with',
                      style: TextStyle(
                          fontFamily: 'MoveText',
                          fontSize: 18,
                          color: Colors.grey))),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
              child: ListTile(
                onTap: () =>
                    Navigator.of(context).pushNamed('/EnterTopUpAmount'),
                leading: Container(
                    alignment: Alignment.center,
                    width: 40,
                    height: 55,
                    child: Icon(Icons.credit_card,
                        size: 30, color: AppTheme().getSecondaryColor())),
                horizontalTitleGap: 5,
                contentPadding: const EdgeInsets.only(left: 0),
                title: const Text(
                  'Credit card',
                  style: TextStyle(
                    fontFamily: 'MoveTextMedium',
                    fontSize: 20,
                  ),
                ),
                trailing: Container(
                    width: 40,
                    height: 55,
                    child: const Icon(Icons.arrow_forward_ios,
                        size: 17, color: Colors.black)),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 9,
            ),
            const Divider(
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: const Text('Preferred method',
                      style: TextStyle(
                          fontFamily: 'MoveText',
                          fontSize: 18,
                          color: Colors.grey))),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 15, top: 15, left: 20, right: 20),
              child: ListTile(
                onTap: () => context
                    .read<HomeProvider>()
                    .updatePreferredPaymentMethod(method: 'wallet'),
                leading: Container(
                    alignment: Alignment.topCenter,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.mobile_friendly_outlined,
                        size: 35, color: Colors.black)),
                horizontalTitleGap: 5,
                contentPadding: const EdgeInsets.only(left: 0),
                title: const Text(
                  'Wallet',
                  style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 20),
                ),
                subtitle: const Text('Cashless, recommended.'),
                trailing: Visibility(
                  visible:
                      context.watch<HomeProvider>().preferredPaymentMethod ==
                          'wallet',
                  child: Container(
                      width: 40,
                      height: 55,
                      child: Icon(Icons.check_circle,
                          size: 30, color: AppTheme().getSecondaryColor())),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 15, top: 0, left: 20, right: 20),
              child: ListTile(
                onTap: () => context
                    .read<HomeProvider>()
                    .updatePreferredPaymentMethod(method: 'cash'),
                leading: Container(
                    alignment: Alignment.topCenter,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.attach_money_outlined,
                        size: 35, color: Colors.green)),
                horizontalTitleGap: 5,
                contentPadding: const EdgeInsets.only(left: 0),
                title: const Text(
                  'Cash',
                  style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 20),
                ),
                trailing: Visibility(
                  visible:
                      context.watch<HomeProvider>().preferredPaymentMethod ==
                          'cash',
                  child: Container(
                      width: 40,
                      height: 55,
                      child: Icon(Icons.check_circle,
                          size: 30, color: AppTheme().getSecondaryColor())),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
