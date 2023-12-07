import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Helpers/DataParser.dart';
import 'package:dulcetdash/components/Modules/GenericRectButton/GenericRectButton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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
    _autoSelectOptionByName('size', 'standard pizza (23cm)');
    _autoSelectOptionByName('base', 'original');
    _autoSelectOptionByName('cheese', 'normal cheese');

    setState(() {});
  }

  void _autoSelectOptionByName(String key, String optionName) {
    final options = productData['options'][key];
    if (options != null) {
      final autoSelectedOption = options.firstWhere(
        (option) => option['name'] == optionName,
        orElse: () => null,
      );

      if (autoSelectedOption != null) {
        pizzaSelectedOptions[key] = autoSelectedOption;
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pizzaAutoSelectOptions();
  }

  @override
  Widget build(BuildContext context) {
    return Container(height: 120, child: getFirstLineOptions());
  }

  void updateSelectedOption(String key, dynamic selectedOption) {
    setState(() {
      pizzaSelectedOptions[key] = selectedOption;
    });
  }

  Widget getFirstLineOptions() {
    //Check if the options are for a pizza or other products
    var isPizza = productData['options'].containsKey('size');
    bool isEmpty = mapEquals({}, productData['options']);
    var productOptions = productData['options'];

    if (isEmpty) {
      return SizedBox.shrink();
    }

    if (isPizza) {
      final Map<String, dynamic> filteredMap = Map.fromIterable(
        productOptions.keys.where((key) => allowedKeys.contains(key)),
        key: (key) => key,
        value: (key) => productOptions[key],
      );

      return Container(
        // color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (String key in allowedKeys)
              if (pizzaSelectedOptions.containsKey(key))
                _buildOptionRow(key, pizzaSelectedOptions[key]),
            InkWell(
              onTap: () {
                showMaterialModalBottomSheet(
                  backgroundColor: Colors.white,
                  expand: false,
                  bounce: true,
                  duration: Duration(milliseconds: 250),
                  context: context,
                  builder: (context) => LocalModalPizza(pizzaSelectedOptions),
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
      return const SizedBox.shrink();
    }
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
            (pizzaSelectedOptions.keys.length * 1.5),
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
                    fontFamily: 'MoveTextMedium',
                    fontSize: 17,
                    color: AppTheme().getSecondaryColor()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget LocalModalPizza(pizzaSelectedOptionsAlpha) {
    var productOptions = productData['options'];
    final Map<String, dynamic> filteredMap = Map.fromIterable(
      productOptions.keys.where((key) => allowedKeys.contains(key)),
      key: (key) => key,
      value: (key) => productOptions[key],
    );

    print(filteredMap);

    return SafeArea(
      child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: ListView(
              children: [
                for (String key in allowedKeys)
                  if (pizzaSelectedOptionsAlpha.containsKey(key))
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
                        Divider(),
                        ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: filteredMap[key].length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              minVerticalPadding: 0,
                              onTap: () {
                                // setState(() {
                                //   pizzaSelectedOptions[key] =
                                //       filteredMap[key][index];
                                // });
                                updateSelectedOption(
                                    key, filteredMap[key][index]);
                                // print(pizzaSelectedOptionsAlpha[key]);
                              },
                              leading: Icon(
                                Icons.check_circle,
                                color: pizzaSelectedOptionsAlpha[key]['name'] ==
                                        filteredMap[key][index]['name']
                                    ? AppTheme().getPrimaryColor()
                                    : Colors.red,
                              ),
                              title: Text(
                                dataParser.capitalizeWords(
                                    filteredMap[key][index]['name']),
                                style: TextStyle(
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
                          separatorBuilder: (context, index) => Divider(
                            height: 0,
                          ),
                        ),
                        Divider(
                          height: 35,
                          color: Colors.white,
                        )
                      ],
                    ),
                Expanded(child: SizedBox.shrink()),
                GenericRectButton(
                  label: 'Button',
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
