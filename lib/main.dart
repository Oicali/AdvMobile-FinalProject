// Core Flutter material widgets
import 'package:flutter/material.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/addeditaddress.dart';
import 'screens/profile.dart';
import 'screens/editprofile.dart';
import 'screens/accountcreated.dart';
import 'screens/itemdetails.dart';
import 'screens/rentrequest.dart';
import 'screens/mylistings.dart';
import 'screens/postedititem.dart';
import 'screens/incomingrequests.dart';
import 'screens/myrentals.dart';
import 'screens/rentaldetails.dart';
import 'screens/feebreakdown.dart';
import 'screens/saveditems.dart';
import 'screens/myaddresses.dart';
import 'screens/reportissue.dart';
import 'screens/disputedetails.dart';
import 'screens/myreports.dart';
import 'screens/home.dart';
import 'screens/demomenu.dart';
import 'screens/confirmreturn.dart';
import 'screens/splash.dart';

// App entry point
void main() {
  runApp(MyFirstApp());
}

// Root widget: holds theme and named routes
class MyFirstApp extends StatelessWidget {
  //constructor
  const MyFirstApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // First screen shown on launch
      initialRoute: "/splash",

      // Named routes used by Navigator.pushNamed
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
      },

      // App name + teal theme + Plus Jakarta Sans font app-wide
      title: "Pahiram",
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        colorSchemeSeed: const Color(0xFF0F5C5C),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}