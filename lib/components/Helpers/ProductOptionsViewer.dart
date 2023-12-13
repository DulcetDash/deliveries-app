import 'package:cached_network_image/cached_network_image.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Helpers/DataParser.dart';
import 'package:dulcetdash/components/Modules/GenericRectButton/GenericRectButton.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:badges/badges.dart' as badges;

class ProductOptionsViewer extends StatefulWidget {
  final Map productData;

  const ProductOptionsViewer({super.key, required this.productData});

  @override
  State<ProductOptionsViewer> createState() =>
      _ProductOptionsViewerState(productData: productData);
}

class _ProductOptionsViewerState extends State<ProductOptionsViewer> {
  final Map productData;
  Map<String, dynamic> pizzaSelectedOptions = {};
  final List<String> allowedKeys = ['size', 'base', 'cheese'];
  DataParser dataParser = DataParser();

  _ProductOptionsViewerState({required this.productData});

  void _pizzaAutoSelectOptions() {
    if (productData['options'].runtimeType == Map) {
      return;
    }
    // Additional auto-selection based on specific criteria
    _autoSelectOptionByName('size', 'real deal pizza (19cm)');
    _autoSelectOptionByName('base', 'original');
    _autoSelectOptionByName('cheese', 'normal cheese');

    setState(() {});
  }

  void _autoSelectOptionByName(String key, String optionName) {
    if (productData['options'] is List) return;

    final options = productData['options'][key];
    if (options != null) {
      final autoSelectedOption = options.firstWhere(
        (option) => option['name'] == optionName,
        orElse: () => null,
      );

      if (autoSelectedOption != null) {
        context.read<HomeProvider>().updateOptionKeyForProductInGlobals(
            productId: productData['id'], key: key, value: autoSelectedOption);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context
          .read<HomeProvider>()
          .doesOptionsKeyExistForProduct(productData['id'])) {
        context.read<HomeProvider>().addOptionsKeyForProductToGlobals(
            product: productData as Map<String, dynamic>);
      }

      _pizzaAutoSelectOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.15,
        child: getFirstLineOptions());
  }

  void updateSelectedOption(String key, dynamic selectedOption) {
    context.read<HomeProvider>().updateOptionKeyForProductInGlobals(
        productId: productData['id'], key: key, value: selectedOption);
  }

  Widget getFirstLineOptions() {
    //Check if the options are for a pizza or other products
    var isPizza = productData['options'] is Map &&
        productData['options'].containsKey('size');
    var productOptions = productData['options'];

    if (context.read<HomeProvider>().areProductOptionsEmptyFor(
        product: productData as Map<String, dynamic>)) {
      return SizedBox.shrink();
    }

    if (isPizza) {
      final Map<String, dynamic> filteredMap = Map.fromIterable(
        productOptions.keys.where((key) => allowedKeys.contains(key)),
        key: (key) => key,
        value: (key) => productOptions[key],
      );

      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (String key in allowedKeys)
              if (context
                  .watch<HomeProvider>()
                  .globalSelectedOptions[productData['id']]
                  .containsKey(key))
                _buildOptionRow(
                    key,
                    context
                        .watch<HomeProvider>()
                        .globalSelectedOptions[productData['id']][key]),
            InkWell(
              onTap: () {
                showMaterialModalBottomSheet(
                  backgroundColor: Colors.white,
                  expand: false,
                  bounce: true,
                  duration: Duration(milliseconds: 250),
                  context: context,
                  builder: (context) => LocalModalPizza(),
                );
              },
              child: Row(
                children: [
                  Text(
                    'Change',
                    style: TextStyle(
                        fontFamily: 'MoveText',
                        color: AppTheme().getSecondaryColor(),
                        fontSize: 16),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme().getSecondaryColor(),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    } else {
      return Container(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        for (var option in productOptions.sublist(0, 3))
          _buildGenericFastFoodOptionRow(option['title'], option),
        Visibility(
            visible: productOptions.length > 3,
            child: InkWell(
              onTap: () {
                showMaterialModalBottomSheet(
                  backgroundColor: Colors.white,
                  expand: false,
                  bounce: true,
                  duration: Duration(milliseconds: 250),
                  context: context,
                  builder: (context) => LocalModalGeneric(),
                );
              },
              child: Row(
                children: [
                  Text(
                    'More',
                    style: TextStyle(
                        fontFamily: 'MoveText',
                        color: AppTheme().getSecondaryColor(),
                        fontSize: 16),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme().getSecondaryColor(),
                  ),
                ],
              ),
            )),
        Visibility(
            visible: productOptions.length <= 2,
            child: Flexible(
                flex: 1,
                child: Container(
                    width: MediaQuery.of(context).size.width / (3 * 1.5),
                    child: const Opacity(opacity: 0, child: Text('change')))))
      ]));
    }
  }

  Widget LocalModalGeneric() {
    var productOptions = productData['options'];

    return SafeArea(
      child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customize your order',
                      style: TextStyle(
                          fontFamily: 'MoveTextBold',
                          fontSize: 20,
                          color: AppTheme().getGenericDarkGrey()),
                    ),
                    const Divider(),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: productOptions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          minVerticalPadding: 0,
                          onTap: () {
                            // updateSelectedOption(
                            //     key, filteredMap[key][index]);
                          },
                          leading: Icon(
                            Icons.check_circle,
                            // color: context
                            //                 .watch<HomeProvider>()
                            //                 .globalSelectedOptions[
                            //             productData['id']][key]['name'] ==
                            //         filteredMap[key][index]['name']
                            //     ? AppTheme().getPrimaryColor()
                            //     : Colors.grey.shade300,
                          ),
                          title: Text(
                            dataParser.capitalizeWords(
                                productOptions[index]['title']),
                            style: const TextStyle(
                                fontFamily: 'MoveText', fontSize: 17),
                          ),
                          trailing: Text(
                            'N\$${productOptions[index]['price'].toString()}',
                            style: TextStyle(
                                fontFamily: 'MoveText',
                                fontSize: 18,
                                color: AppTheme().getPrimaryColor()),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        height: 0,
                      ),
                    ),
                    const Divider(
                      height: 35,
                      color: Colors.white,
                    )
                  ],
                ),
                const Expanded(child: SizedBox.shrink()),
                GenericRectButton(
                  label: 'Done',
                  labelFontSize: 20,
                  horizontalPadding: 0,
                  actuatorFunctionl: () {
                    Navigator.of(context).pop();
                  },
                  isArrowShow: false,
                )
              ],
            ),
          )),
    );
  }

  Widget _buildGenericFastFoodOptionRow(
      String mainKey, Map<String, dynamic> option) {
    bool isSelected = context.watch<HomeProvider>().isGenericOptionSelected(
        product: productData as Map<String, dynamic>, option: option);

    return Flexible(
      flex: 1,
      child: InkWell(
        onTap: () => context
            .read<HomeProvider>()
            .toggleGenericFastFoodProductOptions(
                product: productData as Map<String, dynamic>, option: option),
        child: badges.Badge(
          badgeContent: isSelected
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                )
              : null,
          badgeStyle: badges.BadgeStyle(
            badgeColor:
                isSelected ? AppTheme().getSecondaryColor() : Colors.white,
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                  width: isSelected ? 2.5 : 1,
                  color: isSelected
                      ? AppTheme().getSecondaryColor()
                      : AppTheme().getGenericDarkGrey()),
              borderRadius: BorderRadius.circular(10),
            ),
            width: MediaQuery.of(context).size.width / (3 * 1.5),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Column(
                children: [
                  Visibility(
                    // visible: option['image'] != null,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 55,
                        child: CachedNetworkImage(
                          fit: BoxFit.contain,
                          imageUrl: option['image'] is List
                              ? option['image'][0]
                              : 'null',
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => SizedBox(
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                height: 55.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.photo,
                            size: 35,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox.shrink()),
                  Text(
                    dataParser.capitalizeWords(mainKey),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                        fontFamily: 'MoveTextMedium', fontSize: 14),
                  ),
                  Text(
                    'N\$${option['price'].toString()}',
                    style: TextStyle(
                        fontFamily: 'MoveTextRegular',
                        fontSize: 17,
                        color: AppTheme().getSecondaryColor()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow(String mainKey, Map<String, dynamic> option) {
    return Flexible(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme().getGenericDarkGrey()),
          borderRadius: BorderRadius.circular(10),
        ),
        width: MediaQuery.of(context).size.width /
            (context
                    .watch<HomeProvider>()
                    .globalSelectedOptions[productData['id']]
                    .keys
                    .length *
                1.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Text(
                dataParser.capitalizeWords(mainKey),
                style:
                    const TextStyle(fontFamily: 'MoveTextBold', fontSize: 17),
              ),
              Text(
                dataParser.capitalizeWords(option['name'].toString()),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'MoveText',
                    color: AppTheme().getGenericDarkGrey()),
              ),
              const Expanded(child: SizedBox.shrink()),
              Text(
                'N\$${option['price'].toString()}',
                style: TextStyle(
                    fontFamily: 'MoveTextRegular',
                    fontSize: 17,
                    color: AppTheme().getSecondaryColor()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget LocalModalPizza() {
    var productOptions = productData['options'];
    final Map<String, dynamic> filteredMap = Map.fromIterable(
      productOptions.keys.where((key) => allowedKeys.contains(key)),
      key: (key) => key,
      value: (key) => productOptions[key],
    );

    return SafeArea(
      child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: ListView(
              children: [
                for (String key in allowedKeys)
                  if (context
                      .watch<HomeProvider>()
                      .globalSelectedOptions[productData['id']]
                      .containsKey(key))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dataParser.capitalizeWords(key),
                          style: TextStyle(
                              fontFamily: 'MoveTextBold',
                              fontSize: 20,
                              color: AppTheme().getGenericDarkGrey()),
                        ),
                        const Divider(),
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: filteredMap[key].length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              minVerticalPadding: 0,
                              onTap: () {
                                updateSelectedOption(
                                    key, filteredMap[key][index]);
                              },
                              leading: Icon(
                                Icons.check_circle,
                                color: context
                                                .watch<HomeProvider>()
                                                .globalSelectedOptions[
                                            productData['id']][key]['name'] ==
                                        filteredMap[key][index]['name']
                                    ? AppTheme().getPrimaryColor()
                                    : Colors.grey.shade300,
                              ),
                              title: Text(
                                dataParser.capitalizeWords(
                                    filteredMap[key][index]['name']),
                                style: const TextStyle(
                                    fontFamily: 'MoveText', fontSize: 17),
                              ),
                              trailing: Text(
                                'N\$${filteredMap[key][index]['price'].toString()}',
                                style: TextStyle(
                                    fontFamily: 'MoveText',
                                    fontSize: 18,
                                    color: AppTheme().getPrimaryColor()),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(
                            height: 0,
                          ),
                        ),
                        const Divider(
                          height: 35,
                          color: Colors.white,
                        )
                      ],
                    ),
                const Expanded(child: SizedBox.shrink()),
                GenericRectButton(
                  label: 'Done',
                  labelFontSize: 20,
                  horizontalPadding: 0,
                  actuatorFunctionl: () {
                    Navigator.of(context).pop();
                  },
                  isArrowShow: false,
                )
              ],
            ),
          )),
    );
  }
}
