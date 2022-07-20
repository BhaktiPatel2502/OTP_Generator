import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/screens/home_screen.dart';

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}

class loginscreen extends StatefulWidget {
  const loginscreen({Key? key}) : super(key: key);

  @override
  _loginscreenState createState() => _loginscreenState();
}

class _loginscreenState extends State<loginscreen> {
  MobileVerificationState currentState = MobileVerificationState.SHOW_MOBILE_FORM_STATE;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  late String verificationId;
  bool showloder = false;

  FirebaseAuth _auth = FirebaseAuth.instance;

  void signInWithPhoneAuthCredential(AuthCredential phoneAuthCredential) async{
    setState(() {
      showloder = true;
    });
    try {
      final authCredential = await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        showloder = false;
      });

      if(authCredential.user != " "){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> homescreen()));
      }

    } on FirebaseAuthException catch (e) {
      setState(() {
        showloder = false;
      });

      _Scaffoldkey.currentState?.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }


  getMobileFormWidget(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        TextField(
          controller: phoneController,
          decoration: InputDecoration(
            hintText: 'Mobile Number',
          ),
        ),
        SizedBox(
          height: 20,
        ),
        FlatButton(
          onPressed: () async{

            setState(() {
              showloder = true;
            });

           await _auth.verifyPhoneNumber (
                phoneNumber: phoneController.text,
                verificationCompleted: (phoneAuthCredential) async{
                    setState(() {
                      showloder = false;
                    });
                   // signInWithPhoneAuthCredential(phoneAuthCredential);
                },
                verificationFailed: (veryficationFailed) async{
                  setState(() {
                    showloder = false;
                  });
                  _Scaffoldkey.currentState?.showSnackBar(SnackBar(content: Text(veryficationFailed.message)));
                },
                codeSent: (verificationId, resendingToken) async{
                  setState(() {
                      showloder = false;

                    currentState = MobileVerificationState.SHOW_OTP_FORM_STATE;
                    this.verificationId = verificationId;
                  });
                },
                codeAutoRetrievalTimeout: (veryficationId) async{

                },
            );
          },
          child: Text('SEND'),
          color: Colors.blue,
          textColor: Colors.white,
        )
      ],
    );
  }

  getOtpFormWidget(context) {
        return Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            TextField(
              controller: otpController,
              decoration: InputDecoration(
                hintText: 'Enter OTP',
              ),
            ),
            SizedBox(
              height: 20,
            ),
            FlatButton(
              onPressed: () async{
                AuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpController.text);

                signInWithPhoneAuthCredential(phoneAuthCredential);
              },
              child: Text('VARIFY'),
              color: Colors.blue,
              textColor: Colors.white,
            )
          ],
        );
  }

 final GlobalKey<ScaffoldState> _Scaffoldkey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _Scaffoldkey,
        body: Container(
            child: showloder ? Center(child: CircularProgressIndicator(),) : currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE
                ? getMobileFormWidget(context)
                : getOtpFormWidget(context),
        ),
    );
  }
}


