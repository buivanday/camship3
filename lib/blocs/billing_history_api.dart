import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:farax/blocs/shop_api.dart';
import 'package:farax/utils/auth_utils.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BillingHistoryApi {
  final String baseUrl;
  final Map<String, SearchBillingResult> cache;
  final http.Client client;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  BillingHistoryApi({
    HttpClient client,
    Map<String, SearchBillingResult> cache,
    this.baseUrl = "https://camships.com:3000/api/Orders/shop/order-histories?access_token=",
  })  : this.client = client ?? http.Client(),
        this.cache = cache ?? <String, SearchBillingResult>{};

  Future<SearchBillingResult> search(String start, String end) async {
    if (cache.containsKey('${start}_${end}_')) {
      return cache['${start}_${end}_'];
    } else {
      final result = await _fetchResults(start, end);
      cache['${start}_${end}_'] = result;

      return result;
    }
  }

  Future<SearchBillingResult> _fetchResults(String start, String end) async {
    SharedPreferences _sharedPreferences = await _prefs;
    String authToken = AuthUtils.getToken(_sharedPreferences);
    final response = await client.get(Uri.parse("$baseUrl$authToken&start=$start&end=$end"));
    final results = json.decode(response.body);
    return SearchBillingResult.fromJson(results);
  }


}

class SearchBillingResult {
  final List<BillingHistoryModel> items;

  SearchBillingResult(this.items);

  factory SearchBillingResult.fromJson(dynamic json) {
    final items = (json as List)
        .cast<Map<String, Object>>()
        .map((Map<String, Object> item) {
      return BillingHistoryModel.fromJson(item);
    }).toList();

    return SearchBillingResult(items);
  }

  bool get isPopulated => items.isNotEmpty;

  bool get isEmpty => items.isEmpty;
}


class BillingHistoryModel {
  final String date;
  final List<ShopOrder> orders;
  final double totalCompleted;
  final double totalFailed;
  final double totalCOD;
  final double totalShippingFee;
  
  BillingHistoryModel({this.date, this.orders, this.totalCOD, this.totalCompleted, this.totalFailed, this.totalShippingFee});
  
  factory BillingHistoryModel.fromJson(Map<String, dynamic> json) {
    return BillingHistoryModel(
      date: json['date'] as String,
      orders: (json['orders'] as List).cast<Map<String, Object>>().map((Map<String, Object> item) {
        return ShopOrder.fromJson(item);
      }).toList() as List<ShopOrder>,
      totalCOD: json['totalCOD'].toDouble() as double,
      totalCompleted: json['totalCompleted'].toDouble() as double,
      totalFailed: json['totalFailed'].toDouble() as double,
      totalShippingFee: json['totalShippingFee'].toDouble() as double
    );
  }
}
