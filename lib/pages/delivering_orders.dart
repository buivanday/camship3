import 'package:farax/all_translations.dart';
import 'package:farax/components/gradient_appbar.dart';
import 'package:farax/components/order_item.dart';
import 'package:flutter/material.dart';

class DeliveringOrders extends StatelessWidget {
  DeliveringOrders(this.orders);
  final List<dynamic> orders;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GradientAppBar(title: allTranslations.text('delivering'),hasBackIcon: true),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.only(left: 16, right: 11),
                child: orders != null && orders.isNotEmpty ? ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, position) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 30, right: 5),
                      child: OrderItem(order: orders[position], isGoToDeliveringPage: true),
                    );
                  }
                ) : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset('icons/no-order.png'),
                      SizedBox(height: 16),
                      Text(allTranslations.text('no_order_text'))
                    ]
                  )
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}