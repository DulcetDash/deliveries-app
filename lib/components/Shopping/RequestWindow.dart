import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nej/components/Helpers/AppTheme.dart';
import 'package:shimmer/shimmer.dart';

class RequestWindow extends StatefulWidget {
  const RequestWindow({Key? key}) : super(key: key);

  @override
  State<RequestWindow> createState() => _RequestWindowState();
}

class _RequestWindowState extends State<RequestWindow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: ListView(
        children: [
          Header(),
          ShoppingList(),
          PaymentSection(),
          DeliverySection(),
          CancellationSection()
        ],
      )),
    );
  }
}

//Header
class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      // color: Colors.red,
      child: getCurrentState(context: context),
    );
  }

  //Get current state
  Widget getCurrentState({required BuildContext context}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // LoadingAnimationWidget.stretchedDots(
        //     color: AppTheme().getPrimaryColor(), size: 50),
        Placeholder(
          fallbackHeight: 50,
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          'Finding you a shopper...',
          style: TextStyle(fontSize: 16, fontFamily: 'MoveTextMedium'),
        )
      ],
    );
  }
}

//Shopping list
class ShoppingList extends StatelessWidget {
  const ShoppingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade100.withOpacity(0.7),
            border: Border(
                top: BorderSide(width: 0.5, color: Colors.grey),
                bottom: BorderSide(width: 0.5, color: Colors.grey))),
        height: 145,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      getThumbnailItem(context: context),
                      SizedBox(
                        width: 15,
                      ),
                      getThumbnailItem(context: context),
                      SizedBox(
                        width: 15,
                      ),
                      getThumbnailItem(context: context),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: Colors.grey.shade600,
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Your shopping list',
                style: TextStyle(fontSize: 15),
              )
            ],
          ),
        ));
  }

  //Get images thembnail array
  List<Widget> imagesArray({required BuildContext context}) {
    List tmpFinal = [];
    return [];
  }

  //Thumbnail items
  Widget getThumbnailItem({required BuildContext context}) {
    return Container(
        height: 50,
        width: 60,
        color: Colors.amber,
        child: CachedNetworkImage(
          imageUrl: 'https://picsum.photos/200/300',
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 20.0,
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: 48.0,
                height: 48.0,
                color: Colors.white,
              ),
            ),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.error,
            size: 30,
            color: Colors.grey,
          ),
        ));
  }
}

//Payment section
class PaymentSection extends StatelessWidget {
  const PaymentSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Payment',
                    style: TextStyle(
                        fontFamily: 'MoveTextMedium',
                        fontSize: 17,
                        color: Colors.grey.shade600),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.info,
                    size: 15,
                    color: Colors.grey.shade500,
                  )
                ],
              ),
              Text(
                'N\$1450',
                style: TextStyle(
                    fontFamily: 'MoveTextMedium',
                    fontSize: 18,
                    color: AppTheme().getPrimaryColor()),
              )
            ],
          ),
          ListTile(
            contentPadding: EdgeInsets.only(top: 15),
            horizontalTitleGap: -15,
            leading: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                Icons.circle,
                size: 10,
                color: Colors.black,
              ),
            ),
            title: Text(
              'Cash',
              style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 19),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Not yet picked up from you.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          )
        ],
      ),
    ));
  }
}

//Delivery section
class DeliverySection extends StatelessWidget {
  const DeliverySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border(top: BorderSide(width: 0.5, color: Colors.grey))),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery',
                  style: TextStyle(
                      fontFamily: 'MoveTextMedium',
                      fontSize: 17,
                      color: Colors.grey.shade600),
                )
              ],
            ),
            ListTile(
              contentPadding: EdgeInsets.only(top: 15),
              horizontalTitleGap: -15,
              leading: Icon(
                Icons.location_pin,
                size: 20,
                color: Colors.black,
              ),
              title: Text(
                'Klein Windhoek',
                style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 18),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  'Street & city',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

//Cancel section
class CancellationSection extends StatelessWidget {
  const CancellationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('Cancellation action');
      },
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 20),
        child: Container(
          child: Text(
            'Cancel the shopping',
            style: TextStyle(
                fontFamily: 'MoveTextMedium',
                fontSize: 17,
                color: AppTheme().getErrorColor()),
          ),
        ),
      ),
    );
  }
}
