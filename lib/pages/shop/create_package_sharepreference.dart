import 'package:shared_preferences/shared_preferences.dart';



class CreatePackageSharePreference{
  //
  Future<bool> _isPageOneExist() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPageOneExist') == null ? false : prefs.getBool('isPageOneExist');
  }
  Future<bool> isPageTwoExist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPageTwoExist') == null
        ? false
        : prefs.getBool('isPageTwoExist');
  }
  Future<bool> isPageThreeExist() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isPageThreeExist') == null ? false : prefs.getBool('isPageThreeExist');
  }
  Future<bool> _setPageOneExist(bool isValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool('isPageOneExist', isValue);
  }
  Future<bool> setPageTwoExist(bool isValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool('isPageTwoExist', isValue);
  }

  Future<bool> setPageThreeExist(bool isValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool('isPageThreeExist', isValue);
  }
  Future<bool> getPageBill() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isBillExist') == null ? false : prefs.getBool('isBillExist');
  }
  Future<bool> setPageBill(bool isValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool('isBillExist', isValue);
  }
  //delivertime
  Future<bool> setDeliverytime(double time) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setDouble('Deliverytime', time) == null ? 0 : prefs.setDouble('Deliverytime', time);
  }

  Future<double> getDeliverytime() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('Deliverytime') == null ? 0 : prefs.getDouble('Deliverytime');
  }

  //weight
   Future<bool> setWeight(int actualWeight) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt('Weight', actualWeight) == null ? 0 : prefs.setInt('Weight', actualWeight);
  }

  Future<int> getWeight() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('Weight') ==0 ? 0 : prefs.getInt('Weight');
  }
  //
   Future<bool> setWeightNumber(double number) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setDouble('WeightNumber', number) == null ? 0 : prefs.setDouble('WeightNumber', number);
  }

  Future<double> getWeightNumber() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('WeightNumber') ==null? 0 : prefs.getDouble('WeightNumber');
  }

//
Future<bool> setLengthNumber(double number) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setDouble('LengthNumber', number) ;//== null ? 0 : prefs.setDouble('LengthNumber', number);
  }

  Future<double> getLenghtNumber() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('LengthNumber') ==null ? 0 : prefs.getDouble('LengthNumber');
  }
//
Future<bool> setWidthNumber(double number) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setDouble('WidthNumber', number) ;//== null ? 0 : prefs.setDouble('WidthNumber', number);
  }

  Future<double> getWitdthNumber() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('WidthNumber') ==null? 0 : prefs.getDouble('WidthNumber');
  }
  //
Future<bool> setHeightNumber(double number) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setDouble('HeightNumber', number) ;//== null ? 0 : prefs.setDouble('HeightNumber', number);
  }

  Future<double> getHeightNumber() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('HeightNumber') ==null ? 0 : prefs.getDouble('HeightNumber');
  }
  //
  Future<bool> setPackageType(String packageType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('packageType', packageType) ;
  }

  Future<String> getPackageType() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('packageType') ?? prefs.getString('packageType');
  }
  //
  Future<bool> setNoteTxt(String packageType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('NoteTxt', packageType) ;
  }

  Future<String> getNoteTxt() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('NoteTxt') ?? prefs.getString('NoteTxt');
  }
  // page 3 
  //===================
  Future<bool> setWhoPay(int number) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt("WhoPay", number);
  }
   Future<int> getWhoPay() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('WhoPay') == null ? 0 : prefs.getInt('WhoPay');
  }
  //==========================
  Future<bool> setService(int number) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt("Service", number);
  }
   Future<int> getService() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('Service') ==0 ? 0 : prefs.getInt('Service');
  }
  //========
  Future<bool> setTotalService(double number) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setDouble('TotalService', number) == null ? 0 : prefs.setDouble('TotalService', number);
  }

  Future<double> getTotalService() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('TotalService') ==0 ? 0 : prefs.getDouble('TotalService');
  }
  //=======
  Future<bool> setPromptionCode(String packageType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('PromptionCode', packageType) ;
  }

  Future<String> getPromptionCode() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('PromptionCode') ?? prefs.getString('PromptionCode');
  }
  //==============
  //delete ==================================================================\
  //==========

  removeValue() async{
    final SharedPreferences pref =await SharedPreferences.getInstance();
    bool check;
    check = await pref.remove('Deliverytime');
    print('pfre'+check.toString());
    check = await pref.remove('HeightNumber');
    check = await pref.remove('LengthNumber');
    check = await pref.remove('NoteTxt');
    check = await pref.remove('packageType');
    check = await pref.remove('isPageThreeExist');
  
    check = await pref.remove('PromptionCode');
    check = await pref.remove('Service');
    check = await pref.remove('TotalService');
    check = await pref.remove('Weight');
    check = await pref.remove('WeightNumber');
    check = await pref.remove('WhoPay');
    check = await pref.remove('WidthNumber');
    check = await pref.remove('dataPageOne');
  }
}