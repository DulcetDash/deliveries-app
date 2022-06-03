import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nej/components/GenericRectButton.dart';
import 'package:nej/components/Helpers/AppTheme.dart';
import 'package:nej/components/PaymentSetting.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';

class FareDisplay extends StatefulWidget {
  const FareDisplay({Key? key}) : super(key: key);

  @override
  State<FareDisplay> createState() => _FareDisplayState();
}

class _FareDisplayState extends State<FareDisplay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Column(
        children: [MapPreview(), FarePreview()],
      ),
    );
  }
}

//Preview the map
class MapPreview extends StatelessWidget {
  const MapPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue),
      height: MediaQuery.of(context).size.height * 0.45,
      width: MediaQuery.of(context).size.width,
      child: Text('MAP preview'),
    );
  }
}

//Preview the prices
class FarePreview extends StatelessWidget {
  const FarePreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Text(
                'Economy',
                style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 18),
              ),
            ),
            Divider(
              height: 25,
            ),
            Expanded(
              child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return CarInstance();
                  },
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: 2),
            ),
            PaymentMethodSelector(),
            SafeArea(
              top: false,
              child: GenericRectButton(
                  label: 'Confirm',
                  labelFontSize: 20,
                  actuatorFunctionl: () => {}),
            ),
          ],
        ),
      ),
    );
  }
}

//Payment method
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: InkWell(
        onTap: () => showMaterialModalBottomSheet(
          bounce: true,
          duration: Duration(milliseconds: 250),
          context: context,
          builder: (context) => PaymentSetting(),
        ),
        child: Container(
          // color: Colors.amber,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 35,
                height: 35,
                child: Image.asset(context
                    .read<HomeProvider>()
                    .getCleanPaymentMethod_nameAndImage()['image']!),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                context
                    .read<HomeProvider>()
                    .getCleanPaymentMethod_nameAndImage()['name']!,
                style: TextStyle(
                    fontFamily: 'MoveTextMedium',
                    fontSize: 18,
                    color: AppTheme().getPrimaryColor()),
              ),
              SizedBox(
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 13,
                  color: AppTheme().getPrimaryColor(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//Car instance
class CarInstance extends StatelessWidget {
  const CarInstance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        leading: Container(
            // color: Colors.red,
            child: SizedBox(
          width: 80,
          height: 60,
          child: Image.asset('assets/Images/normaltaxi2.jpeg'),
        )),
        title: Text(
          'Normal Taxi',
          style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 16),
        ),
        subtitle: Text('Affordable'),
        trailing: Text(
          'N\$50',
          style: TextStyle(fontFamily: 'MoveTextBold', fontSize: 21),
        ),
      ),
    );
  }
}

//Computing fare screen
class ComputingFaresLoader extends StatelessWidget {
  const ComputingFaresLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        width: MediaQuery.of(context).size.width,
        child: Text('Computing fares'),
      ),
    );
  }
}
