import 'package:farax/components/hex_color.dart';
import 'package:farax/pages/congratulation.dart';
import 'package:farax/pages/receipt.dart';
import 'package:flutter/material.dart';
import '../all_translations.dart';
import '../components/gradient_appbar.dart';
import '../utils/network_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_utils.dart';

class ItemReturned extends StatefulWidget {
  const ItemReturned({
    Key key,
    @required this.order
  }) : super(key: key);

  final dynamic order;

  @override
  _ItemReturnedState createState() => _ItemReturnedState();
}

class _ItemReturnedState extends State<ItemReturned>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
	SharedPreferences _sharedPreferences;
  bool _hadChange = false;
  List<dynamic> _items = new List<dynamic>();
  String reason = '';
  TextEditingController _reasonController = new TextEditingController();
  Future _confirmInShop() async {
    _sharedPreferences = await _prefs;
		String authToken = AuthUtils.getToken(_sharedPreferences);
    var responseJson = await NetworkUtils.postWithBody(authToken, '/api/Orders/${widget.order['id']}/completed', {
      'items': _items,
      'reason': _reasonController.text
    });

    Navigator.of(context).pop();
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => new Receipt(order: responseJson, isReturnedOrder: true, returnedOrders: widget.order['orderPackages']['items'], reason: reason)
    ));
  }

  _haveChanged(bool change, int index, int amount) {
    setState(() {
      widget.order['orderPackages']['items'][index]['haveChanged'] = change;
      widget.order['orderPackages']['items'][index]['returnAmount'] = amount;
    });
    bool haveChanged = false;
    for(var i = 0; i < widget.order['orderPackages']['items'].length; i ++) {
      print(widget.order['orderPackages']['items'][i]);
      if(widget.order['orderPackages']['items'][i]['returnAmount'] > 0) {
        haveChanged = true;
      }
    }
    setState(() {
      _hadChange = haveChanged;
      _items = widget.order['orderPackages']['items'];
    });
  }

  @override
  Widget build(BuildContext context) {
    String extraService = widget.order['orderPackages']['extraService'];
    List<Widget> list = new List<Widget>();
    if(extraService == 'cod') {
      for(var i = 0; i < widget.order['orderPackages']['items'].length; i ++) {
        dynamic orderItems = widget.order['orderPackages']['items'][i];
        orderItems['index'] = i;
        orderItems['haveChanged'] = false;
        final max = orderItems['amount'];
        list.add(new OrderItemReturned(item: orderItems, max: max, haveChanged: _haveChanged,));
      }
    }
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: <Widget>[
            GradientAppBar(title: allTranslations.text('item_were_returned'), hasBackIcon: true,),
            Expanded(
              flex: 1,
              child: Container(
                color: Color.fromRGBO(241, 242, 242, 1),
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 10),
                        child: Text(allTranslations.text('please_select_items_were_returned'), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold),),
                      ),
                      Expanded(
                        flex: _hadChange == true ? 5 : 1,
                        child: ListView(
                          children: list,
                        ),
                      ),
                      _hadChange == true ? Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.only(top: 40, left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(allTranslations.text('please_tell_us_why_do_you_return'), style: TextStyle(color: HexColor('#455A64'), fontWeight: FontWeight.bold)),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: allTranslations.text('please_enter_your_reason'),
                                  labelStyle: TextStyle(
                                    fontSize: 14,
                                    color: HexColor('#90A4AE')
                                  )
                                ),
                                controller: _reasonController,
                              )
                            ],
                          ),
                        ),
                      ) : IgnorePointer(
                        ignoring: true,
                        child: Opacity(opacity: 0.0,),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: Color.fromRGBO(241, 242, 242, 1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                  child: RaisedButton(
                    onPressed: _confirmInShop,
                    color: Color.fromRGBO(253, 134, 39, 1),
                    textColor: Colors.white,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Center(
                        child: Text(allTranslations.text('submit').toUpperCase(), style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
            )
          ],
        )
    );
  }
}

class OrderItemReturned extends StatefulWidget {
  const OrderItemReturned({
    Key key,
    @required this.item,
    @required this.max,
    this.haveChanged
  }) : super(key: key);

  final dynamic item;
  final int max;

  final Function(bool, int, int) haveChanged;
  @override
  _OrderItemReturnedState createState() => _OrderItemReturnedState();
}

class _OrderItemReturnedState extends State<OrderItemReturned> {
  bool isClickMinus = false;
  bool isClickAdd = false;
  int _returnAmount = 0;

  @override
  void initState() {
    super.initState();
    _returnAmount = widget.item['returnAmount'];
  }

  @override
  void dispose() {
    _returnAmount = 0;
    super.dispose();
  }

  void add() {
    setState(() {
      if(_returnAmount >= 0 && _returnAmount < widget.max) {
        _returnAmount++;
        isClickAdd = true;
        isClickMinus = false;
        widget.item['returnAmount'] = _returnAmount;
        if(_returnAmount == 0) {
          isClickMinus = false;
          isClickAdd = false;
          widget.haveChanged(false, widget.item['index'], _returnAmount);
        } else {
          widget.haveChanged(true, widget.item['index'], _returnAmount);
        }
      } else {
        widget.item['returnAmount'] = _returnAmount;
        widget.haveChanged(false, widget.item['index'], _returnAmount);
      }
    });
  }

  void minus() {
    setState(() {
      if (_returnAmount > 0 && _returnAmount <= widget.max) {
        _returnAmount--;
        isClickAdd = false;
        isClickMinus = true;
        widget.item['returnAmount'] = _returnAmount;
        if(_returnAmount == 0) {
          isClickMinus = false;
          isClickAdd = false;
          widget.haveChanged(false, widget.item['index'], _returnAmount);
        } else {
          widget.haveChanged(true, widget.item['index'], _returnAmount);
        }
      } else {
        widget.item['returnAmount'] = _returnAmount;
        widget.haveChanged(false, widget.item['index'], _returnAmount);
      }

      
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.item['index'] % 2 == 0 ? Color.fromRGBO(248, 248, 248, 1) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.item['name'], style: TextStyle(color: Color.fromRGBO(80, 101, 110, 1)),),
                SizedBox(height: 4,),
                Text(widget.item['price'].toString() + ' ' + allTranslations.text('usd_per_item'), style: TextStyle(color: Color.fromRGBO(146, 165, 174, 1)),)
              ],
            ),
            Container(
              width: 120.0,
              height: 38.0,
              decoration: BoxDecoration(
                border: new Border.all(
                  color: HexColor('#B0BEC5'),
                  width: 1.0,
                  style: BorderStyle.solid
                ),
                borderRadius: new BorderRadius.all(new Radius.circular(60.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    padding: const EdgeInsets.all(1.0),
                    icon: Icon(Icons.remove, size: 16, color: HexColor(isClickMinus ? '#0099CC' : '#B0BEC5'),),
                    onPressed: minus,
                  ),
                  Text(_returnAmount.toString(), style: TextStyle(color: HexColor(isClickAdd || isClickMinus ? '#FF3333' : '#455A64'), fontWeight: FontWeight.bold),),
                  IconButton(
                    padding: const EdgeInsets.all(1.0),
                    icon: Icon(Icons.add, size: 16, color: HexColor(isClickAdd ? '#0099CC' : '#B0BEC5')),
                    onPressed: add,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}