import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';

class CartIcon extends StatelessWidget {
  const CartIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/cart');
      },
      child: Container(
          child: context.watch<HomeProvider>().CART.isEmpty
              ? Icon(
                  Icons.shopping_cart,
                  size: 30,
                )
              : badges.Badge(
                  badgeContent: context.watch<HomeProvider>().CART.isEmpty
                      ? null
                      : Text(
                          context.watch<HomeProvider>().CART.length.toString(),
                          style: TextStyle(color: Colors.white)),
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: AppTheme().getPrimaryColor(),
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    size: 30,
                  ),
                )),
    );
  }
}
