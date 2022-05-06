import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nej/components/GenericRectButton.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
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
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(
          children: [
            Header(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return ProductModel(
                        indexProduct: index + 1,
                        productData: context.watch<HomeProvider>().CART[index],
                      );
                    },
                    separatorBuilder: (context, index) => Divider(
                          height: 50,
                        ),
                    itemCount: context.watch<HomeProvider>().CART.length),
              ),
            ),
            GenericRectButton(
                label: 'Place order',
                labelFontSize: 22,
                actuatorFunctionl: () {
                  Navigator.of(context).pushNamed('/paymentSetting');
                })
          ],
        )));
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
                      Icon(Icons.arrow_back),
                      SizedBox(
                        width: 4,
                      ),
                      Text('CART',
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
                  context.watch<HomeProvider>().getCartTotal(),
                  style: TextStyle(
                      fontFamily: 'MoveTextMedium',
                      fontSize: 20,
                      color: Colors.green),
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
                fit: BoxFit.cover,
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
                  Icons.error,
                  size: 30,
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
                SizedBox(
                  height: 38,
                  child: Text(
                    productData['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 15, fontFamily: 'MoveTextMedium'),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  '${productData['price']} • ${getItemsNumber()}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                )
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
      return '$items items';
    } else {
      return '$items item';
    }
  }
}
