import 'package:farax/components/hex_color.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/material.dart';
import '../components/gradient_appbar.dart';
import '../all_translations.dart';

class SearchAddress extends StatefulWidget {
  @override
  _GetStartedState createState() => _GetStartedState();
}

class _GetStartedState extends State<SearchAddress> {
  var _addressController = new TextEditingController();
  var _predictions;
  var _currentAddress;
  bool isChoose=false;
  bool isLoading =false;

  @override
  void dispose(){
    super.dispose();
    _addressController.dispose();
  }
  Future _searchAddress(String address) async {
    if(address == ''||address.length==0) {
      setState(() {
        _predictions = null;

        isLoading =false;
        isChoose= false;
      });
    } else {
      setState(() {
       isLoading = true;
      });
      var responseJson = await NetworkUtils.httpGetAddress(address);
      var predictions = responseJson['predictions'];

      if(responseJson['status'] == 'OK') {
        setState(() {
          _predictions = predictions;
          isLoading =false;
           isChoose= false;
        });
      } else {
        setState(() {
          isLoading =false;
           isChoose= false;
        });
      }
    }
  }

   _onDone() async {
    var responseJson = await NetworkUtils.httpGetAddressDetail(_currentAddress['place_id']);
    Navigator.pop(context, responseJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            PreferredSize(
              child: new Container(
                padding: new EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        color: Colors.white,
                        alignment: Alignment.centerLeft,
                        onPressed: () {
                          Navigator.pop(context);
                        }
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Align(
                          child: Text(allTranslations.text('search'), style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 18.0
                          ))
                        ),
                      ),
                      flex: 2,
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child:isChoose? InkWell(
                            onTap: _onDone,
                            child: Text(allTranslations.text('done').toUpperCase(), style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 18.0
                              )
                            ),
                          ):null,
                        )
                      ),
                      flex: 1,
                    )
                  ],
                ),
                decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                    colors: [
                      Color.fromRGBO(0, 201, 232, 1),
                      Color.fromRGBO(0, 153, 204, 1)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter
                  ),
                  boxShadow: [
                    new BoxShadow(
                      color: Colors.grey[500],
                      blurRadius: 20.0,
                      spreadRadius: 1.0,
                    )
                  ]
                ),
              ),
              preferredSize: new Size(
                MediaQuery.of(context).size.width,
                66.0
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 38.0),
                child: Column(
                  children: <Widget>[
                    Theme(
                      data: new ThemeData(
                        hintColor: HexColor('#DFE4EA')
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          autofocus:  true,
                          decoration: InputDecoration(
                            labelText: allTranslations.text('address'),
                            labelStyle: TextStyle(color: HexColor('#B0BEC5'), fontSize: 14.0),
                            suffixIcon: isChoose ? InkWell(
                              onTap: () {

                                setState(() {
                                  isChoose = false;
                                  _predictions=null;
                                  WidgetsBinding.instance.addPostFrameCallback((_){
                                    _addressController.clear();

                                 // isLoading = false;
                                  _predictions=null;
                                  });
                                });
                              },
                              child: Icon(Icons.close, size: 16),
                            ) : IgnorePointer(ignoring: true, child: Opacity(opacity: 0.0,),)
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          controller: _addressController,

                          onChanged: (String address) {
                            print(isChoose.toString()+" "+isLoading.toString());
                            _searchAddress(address);

                          },
                          style: TextStyle(color: HexColor('#455A64')),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.0,),
                    Container(
                      height: 4.0,
                      width: double.infinity,
                      color: HexColor('#ECEFF1'),
                    ),
                    Expanded(
                      flex: 1,
                      child: Stack(
                        children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _predictions != null   &&!isChoose ? ListView.builder(
                          itemCount: _predictions.length,
                          itemBuilder: (context, position) {
                            return InkWell(
                              onTap: () {
                                _addressController.text = _predictions[position]['description'];
                                setState(() {
                                  _currentAddress = _predictions[position];
                                  isChoose =true;
                                  isLoading =false;
                                });
                              },
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 12.0,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Icon(Icons.location_on, color: HexColor('#B0BEC5'),),
                                      SizedBox(width: 8.0,),
                                      Flexible(
                                        child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(_predictions[position]['structured_formatting']['main_text']!=null?
                                          _predictions[position]['structured_formatting']['main_text']:""
                                          ,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            softWrap: false,
                                            style: TextStyle(color: HexColor('#455A64'), fontSize: 14.0),),
                                          SizedBox(height: 2.0,),
                                          Text(_predictions[position]['structured_formatting']['secondary_text']!=null?
                                            _predictions[position]['structured_formatting']['secondary_text'] : "",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            softWrap: false,
                                            style: TextStyle(color: HexColor('#B0BEC5'), fontSize: 12.0),),
                                        ],
                                      ))
                                    ],
                                  ),
                                  SizedBox(height: 12.0,),
                                  Divider(height: 1.0, color: HexColor('#DFE4EA'),)
                                ],
                              ),
                            );
                          }
                        ) :IgnorePointer(ignoring: true, child: Opacity(opacity: 0.0,),),
                          ),
                          isLoading ? Center(
                            child: CircularProgressIndicator(strokeWidth: 3,),) :
                            Opacity(opacity: 0.0,)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}
