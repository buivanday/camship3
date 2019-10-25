import 'dart:io';
import 'dart:typed_data';

import 'package:farax/components/hex_color.dart';
import 'package:farax/pages/search_address.dart';
import 'package:farax/utils/network_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/gradient_appbar.dart';
import '../all_translations.dart';
import 'get_started.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:farax/services/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import '../utils/auth_utils.dart';

class ChooseOnMap extends StatefulWidget {
  const ChooseOnMap(
      {Key key,
      this.isAddAddressBook = false,
      this.isGetStarted = false,
      this.isCreatePackage = false,
      this.isConfirmPending = false,
      this.oldData})
      : super(key: key);

  final bool isAddAddressBook;
  final bool isCreatePackage;
  final bool isGetStarted;
  final bool isConfirmPending;
  final Map<String, dynamic> oldData;
  @override
  _ChooseOnMapState createState() => _ChooseOnMapState();
}

class _ChooseOnMapState extends State<ChooseOnMap> {
  var _addressController = new TextEditingController();
  GlobalKey _scaffoldKey;
  Location location = Location();
  Marker marker;
  static LatLng _center = LatLng(11.566531, 104.853784);
  LatLng _lastMapPosition = _center;
  Set<Marker> _markers = {};
  // Set<Polyline> _polylines = {};
  List<Map<String, dynamic>> zones;
  bool _isValid = false;
  Uint8List markerIcon;
  Geolocator _geolocator;
  Position _position;
  GoogleMapController mapController;
  var network;
  bool isOffline = false;
  bool isLoading = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences _sharedPreferences;
  Timer _timer;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _getAddress(lat, lng) async {
    var responseJson = await NetworkUtils.postWithBodyWithoutAuth(
        '/api/Zones/find-address', {"lat": lat, "lng": lng});
      if(mounted)
        setState(() {
                  isLoading = true;
                });
      else{
        isLoading = true;
      }
    return responseJson;
  }

  Future<LocationData> _getLocation() async {
    LocationData currentLocation;
    try {
      bool hasPermission = await location.hasPermission();
      if(hasPermission) {
        currentLocation = await location.getLocation();
      } else {
        bool requestPermission = await location.requestPermission();
        if(requestPermission) {
          currentLocation = await location.getLocation();
        }
      }
      return currentLocation;
    } catch (e) {

      setState(() {
                  isLoading = true;
                });
      // currentLocation = null;
      throw e;
    }

  }

  void _onMapCreated(GoogleMapController controller) async {

    if (Platform.isIOS) {
      markerIcon = await getBytesFrommAsset('icons/current.png', 80);
    } else {
      markerIcon = await getBytesFrommAsset('icons/current.png', 70);
    }
    mapController = controller;
    try {
      _getLocation().then((LocationData location) async {
        mapController?.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                location.latitude,
                location.longitude,
              ),
              zoom: 16.0,
            ),
          ),
        );



        try {
          var json = await _getAddress(location.latitude, location.longitude)
              .then((_) {
            _addressController.text = _.first["formattedAddress"];
            _lastMapPosition =
                new LatLng(location.latitude, location.longitude);

            WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
                  isLoading = true;
                }));
          });
          _setMarkers();
        } catch (e) {
          print('Co loi khong lay dc');
          print(1.toString() + e.toString());
        }
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
                  isLoading = true;
                }));
      print('Co loi khong lay dc');
      print(2.toString() + e);
    }
  }

  void _setMarkers() async {
    if (Platform.isIOS) {
          markerIcon = await getBytesFrommAsset('icons/current.png', 80);
        } else {
          markerIcon = await getBytesFrommAsset('icons/current.png', 70);
        }

        if(_lastMapPosition != null) {
          _markers = {
            Marker(
              // This marker id can be anything that uniquely identifies each marker.
              markerId: MarkerId(_lastMapPosition.toString()),
              position: _lastMapPosition,
              icon: BitmapDescriptor.fromBytes(
                  markerIcon), //BitmapDescriptor.fromAsset('icons/current.png'),
            )
          };
        } else {
          _markers = {
            Marker(
              // This marker id can be anything that uniquely identifies each marker.
              markerId: MarkerId(_center.toString()),
              position: _center,
              icon: BitmapDescriptor.fromBytes(
                  markerIcon), //BitmapDescriptor.fromAsset('icons/current.png'),
            )
          };
        }

        if(mounted) {
          setState(() {
            _markers = _markers;
          });
        } else {
          _markers = _markers;
        }
  }

  void _onCameraMove(CameraPosition position) async {
    if (Platform.isIOS) {
      markerIcon = await getBytesFrommAsset('icons/current.png', 80);
    } else {
      markerIcon = await getBytesFrommAsset('icons/current.png', 70);
    }
    setState(() {
      _lastMapPosition = position.target;
      _isValid = false;
      _markers = {
        Marker(
          // This marker id can be anything that uniquely identifies each marker.
          markerId: MarkerId(position.target.toString()),
          position: position.target,
          icon: BitmapDescriptor.fromBytes(
              markerIcon), //BitmapDescriptor.fromAsset('icons/current.png'),
        )
      };
    });
  }

  void _onCameraIdle() async {
    //final coordinates = new Coordinates(_lastMapPosition.latitude,_lastMapPosition.longitude);
    try {
      // print(coordinates);
      //var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      //addresses  = await _get
      // print(addresses);
      // _addressController.text = addresses.first.addressLine;
      if(_isValid == false && _markers.length == 0) {
        _setMarkers();
      }
      var json = await _getAddress(
              _lastMapPosition.latitude, _lastMapPosition.longitude)
          .then((_) {
        _addressController.text = _.first["formattedAddress"];
      });

      setState(() {
        _isValid = true;
      });
    } catch (e) {
      print('loi');
      print(e);
    }
  }

  void _settingModalBottomSheet(context, List<dynamic> zones) async {
    setState(() {
      isLoading = true;
    });
    List<Widget> list = new List<Widget>();
    for (var i = 0; i < zones.length; i++) {
      dynamic _store = zones[i];
      _store['index'] = i;
      list.add(new ListTile(
          leading: new Icon(Icons.location_city),
          title: new Text(_store['name']),
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
          onTap: () {
            Navigator.pop(context, false);
            Navigator.pop(context, {
              'chosenAddress': _addressController.text,
              'selectedZone': _store,
              'lat': _lastMapPosition.latitude,
              'lng': _lastMapPosition.longitude
            });
            // Navigator.push(context, MaterialPageRoute(
            //     builder: (context) => widget.isAddAddressBook == true ?
            //     AddAddressBook(isReturnedFromChooseMap: true, oldData: widget.oldData, chosenAddress: _addressController.text, lat: _lastMapPosition.latitude, lng: _lastMapPosition.longitude) :
            //     widget.isCreatePackage == true ? CreatePackage(isReturnedFromChooseMap: true,oldData: widget.oldData, chosenAddress: _addressController.text, lat: _lastMapPosition.latitude, lng: _lastMapPosition.longitude) : GetStarted()
            // ));
          }));
    }
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: <Widget>[
                Text(
                  allTranslations.text('list_zones'),
                  style: TextStyle(
                      color: HexColor('#455A64'),
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Divider(
                  height: 1.0,
                ),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      children: list,
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  Future<Uint8List> getBytesFrommAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    var network = Provider.of<ConnectionStatus>(context);
    if (network == ConnectionStatus.offline) {
      // NetworkUtils.showSnackBar(_scaffoldKey, null);
      isOffline = true;
    } else {
      isOffline = false;
    }
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          child: Column(
            children: <Widget>[
              GradientAppBar(
                  title: allTranslations.text('choose_on_map'),
                  hasBackIcon: true),
              Expanded(
                child: Stack(
                  children: <Widget>[

                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _center,
                        zoom: 18.0,
                      ),
                      mapType: MapType.normal,
                      zoomGesturesEnabled: true,
                      minMaxZoomPreference: MinMaxZoomPreference(18.0, 18.0),
                      markers: _markers,
                      myLocationEnabled: true,
                      onCameraMove: _onCameraMove,
                      onCameraIdle: _onCameraIdle,
                    ),
                    isOffline || !isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 6,
                        ),
                      )
                    : Opacity(
                        opacity: 0.0,
                      )
                  ],
                ),
              ),
              Container(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28.0, vertical: 28.0),
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Theme(
                        data: new ThemeData(hintColor: HexColor('#DFE4EA')),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: allTranslations.text('address'),
                            labelStyle: TextStyle(
                                color: HexColor('#B0BEC5'), fontSize: 14),
                          ),
                          controller: _addressController,
                          onTap: () async {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchAddress()));
                            if (result != null) {
                              _addressController.text =
                                  result["result"]["formatted_address"];
                              final coordinates = new LatLng(
                                  result['result']['geometry']['location']
                                      ['lat'],
                                  result['result']['geometry']['location']
                                      ['lng']);
                              setState(() {
                                _lastMapPosition = coordinates;
                              });

                              _onCameraMove(
                                  new CameraPosition(target: coordinates));
                              mapController?.moveCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: coordinates,
                                    zoom: 16.0,
                                  ),
                                ),
                              );
                            }
                          },
                          style: TextStyle(color: HexColor('#455A64')),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      RaisedButton(
                        onPressed: _isValid && !isOffline && isLoading
                            ? () async {
                                setState(() {
                                  isLoading = false;
                                });
                                if (widget.isGetStarted) {
                                  Navigator.pop(context, false);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => GetStarted(
                                              isReturnedFromChooseMap: true,
                                              oldData: widget.oldData,
                                              chosenAddress:
                                                  _addressController.text,
                                              lat: _lastMapPosition.latitude,
                                              lng:
                                                  _lastMapPosition.longitude)));
                                } else {
                                  List<dynamic> zones = await NetworkUtils
                                      .fetchWithoutAuthorization('/api/Zones');
                                  var locationDetails = await NetworkUtils
                                      .httpGetDetailFromLatLng(
                                          _lastMapPosition.latitude.toString(),
                                          _lastMapPosition.longitude
                                              .toString());
                                  if (locationDetails['status'] == 'OK') {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    List<dynamic> results =
                                        locationDetails['results'];
                                    if (results.isNotEmpty) {
                                      String longName = '';
                                      String shortName = '';
                                      String address = '';
                                      for (var i = 0; i < results.length; i++) {
                                        if (results[i]['formatted_address']
                                                .length >
                                            address.length) {
                                          address =
                                              results[i]['formatted_address'];
                                        }

                                        if (results[i]['types']
                                            .contains('sublocality')) {
                                          longName = results[i]
                                                      ['address_components'][0]
                                                  ['long_name']
                                              .replaceAll(new RegExp(r' '), '')
                                              .toLowerCase();
                                          shortName = results[i]
                                                      ['address_components'][0]
                                                  ['short_name']
                                              .replaceAll(new RegExp(r' '), '')
                                              .toLowerCase();
                                        }
                                      }

                                      // _addressController.text = address;
                                      var selectedZone = zones.where((zone) {
                                        return zone['name']
                                                    .replaceAll(
                                                        new RegExp(r' '), '')
                                                    .toLowerCase() ==
                                                longName ||
                                            zone['name']
                                                    .replaceAll(
                                                        new RegExp(r' '), '')
                                                    .toLowerCase() ==
                                                shortName;
                                      }).toList();

                                      if (selectedZone.isNotEmpty) {
                                        Navigator.pop(context, {
                                          'chosenAddress':
                                              _addressController.text,
                                          'selectedZone': selectedZone[0],
                                          'lat': _lastMapPosition.latitude,
                                          'lng': _lastMapPosition.longitude
                                        });
                                        // Navigator.pop(context, false);
                                        // Navigator.push(context, MaterialPageRoute(
                                        //     builder: (context) => widget.isAddAddressBook == true ?
                                        //     AddAddressBook(isReturnedFromChooseMap: true, oldData: widget.oldData, chosenAddress: _addressController.text, lat: _lastMapPosition.latitude, lng: _lastMapPosition.longitude) :
                                        //     widget.isCreatePackage == true ? CreatePackage(isReturnedFromChooseMap: true,oldData: widget.oldData, chosenAddress: _addressController.text, selectedZone: selectedZone[0],) : GetStarted()
                                        // ));
                                      } else {
                                        _settingModalBottomSheet(
                                            context, zones);
                                      }
                                    } else {
                                      _settingModalBottomSheet(context, zones);
                                    }
                                  } else {
                                    _settingModalBottomSheet(context, zones);
                                  }
                                }
                              }
                            : null,
                        disabledColor: HexColor('#B0BEC5'),
                        disabledTextColor: Colors.white,
                        color: Color.fromRGBO(253, 134, 39, 1),
                        textColor: Colors.white,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Center(
                            child: Text(
                                allTranslations.text('done').toUpperCase(),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

}
