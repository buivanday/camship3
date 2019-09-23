import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:farax/utils/auth_utils.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ShopApi {
  final String baseUrl;
  final Map<String, SearchResult> cache;
  final http.Client client;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  ShopApi({
    HttpClient client,
    Map<String, SearchResult> cache,
    this.baseUrl = "https://camships.com:3000/api/Orders/shop/orders?access_token=",
  })  : this.client = client ?? http.Client(),
        this.cache = cache ?? <String, SearchResult>{};

  /// Search Github for repositories using the given term
  Future<SearchResult> search(String term) async {
    if (cache.containsKey(term) && term != 'all') {
      return cache[term];
    } else {
      final result = await _fetchResults(term);

      cache[term] = result;

      return result;
    }
  }

  Future<SearchResult> _fetchResults(String term) async {
    SharedPreferences _sharedPreferences = await _prefs;
    String authToken = AuthUtils.getToken(_sharedPreferences);
    final response = await client.get(Uri.parse("$baseUrl$authToken&term=$term"));
    final results = json.decode(response.body);
    return SearchResult.fromJson(results);
  }


}

class SearchResult {
  final List<ShopOrder> items;

  SearchResult(this.items);

  factory SearchResult.fromJson(dynamic json) {
    final items = (json as List)
        .cast<Map<String, Object>>()
        .map((Map<String, Object> item) {
      return ShopOrder.fromJson(item);
    }).toList();

    return SearchResult(items);
  }

  bool get isPopulated => items.isNotEmpty;

  bool get isEmpty => items.isEmpty;
}


class ShopOrder {
  final int noOfOrder;
  final String orderId;
  final String id;
  final dynamic statusId;
  final dynamic lastStatusValue;
  final dynamic currentStatusValue;
  final bool isCountdown;
  final dynamic timeShopBook;
  final dynamic timeReceived;
  final dynamic receiver;
  final dynamic shop;
  final dynamic orderPackages;
  final dynamic delivery;
  final dynamic total;
  final dynamic shippingCost;
  final dynamic totalCOD;
  final dynamic valueOfOrder;
  final dynamic createdOn;
  final dynamic updatedOn;
  final dynamic shipper;
  final dynamic zone;
  final dynamic shipperId;
  final String shopNotes;
  final bool isCashedOut;
  final String pendingReason;
  final String failedReasonFull;
  final String failedReason;
  final String returnedReason;
  
  ShopOrder({this.noOfOrder, this.orderId, this.lastStatusValue, this.currentStatusValue, this.statusId, this.id, this.timeReceived,this.failedReason, this.returnedReason,
   this.isCountdown, this.timeShopBook, this.receiver, this.shop, this.orderPackages, this.shipper, this.isCashedOut, this.pendingReason, this.failedReasonFull,
   this.delivery, this.total, this.shippingCost, this.totalCOD, this.valueOfOrder, this.createdOn, this.updatedOn, this.zone, this.shipperId, this.shopNotes});
  
  factory ShopOrder.fromJson(Map<String, dynamic> json) {
    
    return ShopOrder(
      noOfOrder: json['noOfOrder'] as int,
      orderId: json['orderId'] as String,
      statusId: json['statusId'] as String,
      lastStatusValue: json['lastStatusValue'],
      currentStatusValue: json['currentStatusValue'],
      isCountdown: json['isCountdown'],
      timeShopBook: json['timeShopBook'],
      timeReceived: json['timeReceived'],
      receiver: json['receiver'],
      shop: json['shop'],
      orderPackages: json['orderPackages'],
      delivery: json['delivery'],
      total: json['total'],
      shippingCost: json['shippingCost'],
      totalCOD: json['totalCOD'],
      valueOfOrder: json['valueOfOrder'],
      createdOn: json['createdOn'],
      updatedOn: json['updatedOn'],
      shipper: json['shipper'],
      zone: json['zone'],
      id: json['id'],
      shipperId: json['shipperId'],
      shopNotes: json['shopNotes'],
      isCashedOut: json['isCashedOut'],
      pendingReason: json['pendingReason'],
      failedReason: json['failedReason'],
      failedReasonFull: json['failedReasonFull'],
      returnedReason: json['returnedReason']
    );
  }
}
