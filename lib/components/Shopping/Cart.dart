import 'package:cached_network_image/cached_network_image.dart';
import 'package:dulcetdash/components/Helpers/DataParser.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dulcetdash/components/GenericRectButton.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
              child: Column(
            children: [
              Header(),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: context.watch<HomeProvider>().CART.isNotEmpty
                        ? ListView.separated(
                            itemBuilder: (context, index) {
                              return ProductModel(
                                indexProduct: index + 1,
                                productData:
                                    context.watch<HomeProvider>().CART[index],
                              );
                            },
                            separatorBuilder: (context, index) => Divider(
                                  height: 50,
                                ),
                            itemCount:
                                context.watch<HomeProvider>().CART.length)
                        : Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.15),
                            child: Container(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.shopping_cart,
                                    size: 45,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    'shopping.noItemsForShopping'.tr(),
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 17),
                                  )
                                ],
                              ),
                            ),
                          )),
              ),
              Visibility(
                visible: context.watch<HomeProvider>().CART.isNotEmpty,
                child: GenericRectButton(
                    label: 'shopping.placeOrder'.tr(),
                    labelFontSize: 22,
                    actuatorFunctionl: context
                            .watch<HomeProvider>()
                            .CART
                            .isNotEmpty
                        ? () {
                            Navigator.of(context).pushNamed('/paymentSetting');
                          }
                        : () {}),
              )
            ],
          ))),
    );
  }
}

//Header
class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 20, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    //! Restore the tmp selected product if changed
                    context.read<HomeProvider>().updateSelectedProduct(
                        data: context
                                    .read<HomeProvider>()
                                    .tmp_selectedProduct['name'] !=
                                null
                            ? context.read<HomeProvider>().tmp_selectedProduct
                            : context.read<HomeProvider>().selectedProduct);
                    //! Clear the tmp selected product
                    context
                        .read<HomeProvider>()
                        .updateTMPSelectedProduct(data: {});
                    //...
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back,
                          size: AppTheme().getArrowBackSize()),
                      SizedBox(
                        width: 4,
                      ),
                      Text('shopping.cart'.tr(),
                          style: TextStyle(
                              fontFamily: 'MoveTextBold', fontSize: 24)),
                      Visibility(
                        visible:
                            context.watch<HomeProvider>().CART.isEmpty == false,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, top: 2),
                          child: Text(
                            '• ${context.watch<HomeProvider>().CART.length}',
                            style: TextStyle(
                                fontFamily: 'MoveTextMedium', fontSize: 19),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Text(
                  'N\$${context.watch<HomeProvider>().getCartTotal()}',
                  style: TextStyle(
                      fontFamily: 'MoveTextMedium',
                      fontSize: 20,
                      color: AppTheme().getPrimaryColor()),
                )
              ],
            ),
            Divider(
              height: 40,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}

//Product model
class ProductModel extends StatelessWidget {
  final Map<String, dynamic> productData;
  final int indexProduct;

  const ProductModel(
      {Key? key, required this.productData, required this.indexProduct})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () {
          //! Form the saving data object for the selected item
          Map<String, dynamic> tmpData = {
            "index": productData['index'],
            "name": productData['name'],
            "price": productData['price'],
            "pictures": productData['pictures'],
            "sku": productData['sku'],
            "meta": productData['meta']
          };
          //! Save the previously selected product
          context.read<HomeProvider>().updateTMPSelectedProduct(
              data: context.read<HomeProvider>().selectedProduct);
          //...
          context.read<HomeProvider>().updateSelectedProduct(data: tmpData);
          //Move
          Navigator.of(context).pushNamed('/product_view');
        },
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 30,
              child: Text(
                indexProduct.toString(),
                style: TextStyle(fontSize: 17),
              )),
          Container(
              // color: Colors.red,
              width: 70,
              height: 60,
              child: CachedNetworkImage(
                fit: BoxFit.contain,
                imageUrl: productData['pictures'][0].runtimeType.toString() ==
                        'List<dynamic>'
                    ? productData['pictures'][0][0]
                    : productData['pictures'][0],
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 20.0,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 20.0,
                      height: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.photo,
                  size: 35,
                  color: Colors.grey,
                ),
              )),
          SizedBox(
            width: 10,
          ),
          Container(
            // color: Colors.amber,
            width: MediaQuery.of(context).size.width * 0.45,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productData['name'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontFamily: 'MoveTextMedium'),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'N\$${productData['price']} • ${getItemsNumber()}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const Divider(
                  height: 5,
                  color: Colors.white,
                ),
                Text(
                    DataParser().capitalizeWords(
                        productData['meta']['store'].toString()),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16))
              ],
            ),
          ),
          Expanded(child: SizedBox.shrink()),
          InkWell(
            onTap: () {
              context
                  .read<HomeProvider>()
                  .removeProductFromCart(product: productData);
            },
            child: Container(
              // color: Colors.amber,
              width: 30,
              height: 30,
              child: Icon(
                Icons.delete,
                color: Colors.red.shade500,
              ),
            ),
          )
        ]),
      ),
    );
  }

  //Get the number of items
  String getItemsNumber() {
    int items = productData['items'];

    if (items == 0 || items > 1) {
      return 'delivery.manyItems'.tr(args: ['$items']);
    } else {
      return 'delivery.singleItem'.tr(args: ['$items']);
    }
  }
}
