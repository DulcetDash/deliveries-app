import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Helpers/DataParser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

      print(pizzaSelectedOptions);

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
                print('Change options');
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
}
