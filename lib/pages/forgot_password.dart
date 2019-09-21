import 'package:farax/components/hex_color.dart';
import 'package:flutter/material.dart';
import '../components/gradient_appbar.dart';
import '../all_translations.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<ForgotPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            GradientAppBar(title: allTranslations.text('forgot_password'),hasBackIcon: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: allTranslations.text('form_phone_number'),
                      hintText: allTranslations.text('form_phone_number')
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: allTranslations.text('form_otp'),
                      hintText: allTranslations.text('form_otp')
                    ),
                  ),
                  SizedBox(height: 20),
                  RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.orange,
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(allTranslations.text('form_submit'), style: TextStyle(fontWeight: FontWeight.bold),)
                  ),
                  SizedBox(height: 20),
                  Text(allTranslations.text('60s_left'), style: TextStyle(color: Color.fromRGBO(102, 125, 138, 1)),textAlign: TextAlign.center,),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(allTranslations.text('no_receive_otp'), style: TextStyle(color: Color.fromRGBO(102, 125, 138, 1)),textAlign: TextAlign.center,),
                      SizedBox(width: 5),
                      InkWell(
                        onTap: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) async {
                            await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => new DialogResendOTP()
                          );
                          });
                        },
                        child: Text(allTranslations.text('resend_code'), style: TextStyle(color: Color.fromRGBO(17, 134, 193, 1)),textAlign: TextAlign.center,),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}

class DialogResendOTP extends StatelessWidget {
  const DialogResendOTP({
    Key key,
  }) : super(key: key);


  Future _acceptOrder(BuildContext context) async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0))
          ),
          contentPadding: const EdgeInsets.all(20.0),
          backgroundColor: Colors.white,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Image.asset('icons/bill-alert-icon-title.png'),
              SizedBox(width: 16),
              Text(allTranslations.text('successfully') + '!',
              style: TextStyle(
                color: Color.fromRGBO(20, 156, 206, 1),
                fontWeight: FontWeight.bold,
                fontSize: 16
              )),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(allTranslations.text('resend_otp_content'), style: TextStyle(
                  color: HexColor('#455A64'),
                  fontSize: 14,
                  height: 20/14.0
                )),
                SizedBox(height: 20.0),
                InkWell(
                  onTap: () {_acceptOrder(context);},
                  child: new Container(
                    width: 146,
                    height: 42,
                    decoration: new BoxDecoration(
                      color: HexColor('#FF9933'),
                      borderRadius: BorderRadius.all(Radius.circular(4.0))
                    ),
                    child: new Center(child: new Text(allTranslations.text('ok').toUpperCase(), style: new TextStyle(fontSize: 14.0, color: Colors.white, fontWeight: FontWeight.bold),),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}