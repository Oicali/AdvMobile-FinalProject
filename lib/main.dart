import 'package:flutter/material.dart';
import 'package:advmobile_finalproject/screens/login.dart';
import 'package:advmobile_finalproject/screens/register.dart';
import 'package:advmobile_finalproject/screens/addeditaddress.dart';
import 'package:advmobile_finalproject/screens/profile.dart';
import 'package:advmobile_finalproject/screens/editprofile.dart';
import 'package:advmobile_finalproject/screens/accountcreated.dart';
import 'package:advmobile_finalproject/screens/itemdetails.dart';
import 'package:advmobile_finalproject/screens/rentrequest.dart';
import 'package:advmobile_finalproject/screens/mylistings.dart';
import 'package:advmobile_finalproject/screens/postedititem.dart';
import 'package:advmobile_finalproject/screens/incomingrequests.dart';
import 'package:advmobile_finalproject/screens/myrentals.dart';
import 'package:advmobile_finalproject/screens/rentaldetails.dart';
import 'package:advmobile_finalproject/screens/feebreakdown.dart';
import 'package:advmobile_finalproject/screens/saveditems.dart';
import 'package:advmobile_finalproject/screens/myaddresses.dart';
import 'package:advmobile_finalproject/screens/reportissue.dart';
import 'package:advmobile_finalproject/screens/disputedetails.dart';
import 'package:advmobile_finalproject/screens/myreports.dart';
import 'package:advmobile_finalproject/screens/home.dart';
import 'package:advmobile_finalproject/screens/demomenu.dart';
import 'package:advmobile_finalproject/screens/confirmreturn.dart';
import 'package:advmobile_finalproject/screens/splash.dart';
import 'package:advmobile_finalproject/screens/ratereview.dart';

void main() {
  runApp(PahiramApp());
}

class PahiramApp extends StatelessWidget {
  const PahiramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/splash",

      routes: {

        "/login": (context) => LoginState(),
        "/register": (context) => RegisterState(),
        "/addeditaddress": (context) => AddEditAddressState(),
        "/profile": (context) => ProfileState(),
        "/editprofile": (context) => EditProfileState(),
        "/accountcreated": (context) => AccountCreatedState(),
        "/itemdetails": (context) => ItemDetailsState(),
        "/rentrequest": (context) => RentRequestState(),
        "/mylistings": (context) => MyListingsState(),
        "/postedititem": (context) => PostEditItemState(),
        "/incomingrequests": (context) => IncomingRequestsState(),
        "/myrentals": (context) => MyRentalsState(),
        "/rentaldetails": (context) => RentalDetailsState(),
        "/feebreakdown": (context) => FeeBreakdownState(),
        "/saveditems": (context) => SavedItemsState(),
        "/myaddresses": (context) => MyAddressesState(),
        "/reportissue": (context) => ReportIssueState(),
        "/disputedetails": (context) => DisputeDetailsState(),
        "/myreports": (context) => MyReportsState(),
        "/home": (context) => HomeState(),
        "/demomenu": (context) => DemoMenuState(),
        "/confirmreturn": (context) => ConfirmReturnState(),
        "/splash": (context) => SplashState(),
        "/ratereview": (context) => RateReviewState(),
      },

      title: "Pahiram",
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        colorSchemeSeed: const Color(0xFF0F5C5C),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}