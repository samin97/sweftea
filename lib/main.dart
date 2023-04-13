import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:swfteaproject/constants/constants.dart';
import 'package:swfteaproject/providers/SwfTeaController.dart';
import 'package:swfteaproject/providers/UserProvider.dart';
import 'package:swfteaproject/ui/Announcements.dart';
import 'package:swfteaproject/ui/BettingSingle.dart';
import 'package:swfteaproject/ui/BettingSystem.dart';
import 'package:swfteaproject/ui/ChangePassword.dart';
import 'package:swfteaproject/ui/ChangePinCode.dart';
import 'package:swfteaproject/ui/Contest.dart';
import 'package:swfteaproject/ui/Contests.dart';
import 'package:swfteaproject/ui/Explorer.dart';
import 'package:swfteaproject/ui/Gifts.dart';
import 'package:swfteaproject/ui/Leaderboard.dart';
import 'package:swfteaproject/ui/Leaderboards.dart';
import 'package:swfteaproject/ui/Logout.dart';
import 'package:swfteaproject/ui/MentorPanel.dart';
import 'package:swfteaproject/ui/MerchantPanel.dart';
import 'package:swfteaproject/ui/MissionHome.dart';
import 'package:swfteaproject/ui/MissionInit.dart';
import 'package:swfteaproject/ui/MyAccount.dart';
import 'package:swfteaproject/ui/Notificaltions.dart';
import 'package:swfteaproject/ui/PeopleList.dart';
import 'package:swfteaproject/ui/Screens/Sigin/signin.dart';
import 'package:swfteaproject/ui/SearchUsers.dart';
import 'package:swfteaproject/ui/Settings.dart';
import 'package:swfteaproject/ui/TransferCredit.dart';
import 'package:swfteaproject/ui/ViewHtml.dart';
import 'package:swfteaproject/ui/ViewImage.dart';
import 'package:swfteaproject/ui/mainscreen.dart';
import 'package:swfteaproject/ui/profile.dart';
import 'package:swfteaproject/ui/resetpassword.dart';
import 'package:swfteaproject/ui/Screens/SignUp/signup.dart';
import 'package:swfteaproject/ui/splashscreen.dart';
import 'package:swfteaproject/ui/verifyemail.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        )
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: "SwfTea",
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child,
          );
        },
        getPages: [
          GetPage(
            name: SIGN_IN,
            page: () => SignInPage(),
          ),
          GetPage(
            name: SIGN_UP,
            page: () => SignUpScreen(),
          ),
          GetPage(
            name: RESET_PASSWORD,
            page: () => ResetPasswordScreen(),
          ),
          GetPage(
            name: VERIFY_EMAIL,
            page: () => VerifyEmailScreen(),
          ),
          GetPage(
            name: MAIN_SCREEN,
            page: () => MainScreen(),
          ),
          GetPage(
            name: CONTEST_PAGE,
            page: () => Contests(),
          ),
          GetPage(
            name: CONTEST_SINGLE_PAGE,
            page: () => Contest(),
          ),
          GetPage(
            name: SPLASH_SCREEN,
            page: () => SplashScreen(),
          ),
          GetPage(
            name: PROFILE_SCREEN,
            page: () => Profile(),
          ),
          GetPage(
            name: NOTIFICATION_SCREEN,
            page: () => Notifications(),
          ),
          GetPage(
            name: GIFTS_SCREEN,
            page: () => Gifts(),
          ),
          GetPage(
            name: BETTING_SYSTEM,
            page: () => BettingSystem(),
          ),
          GetPage(
            name: BETTING_SYSTEM_SINGLE,
            page: () => BettingSingle(),
          ),
          GetPage(
            name: EXPLORER_SCREEN,
            page: () => Explorer(),
          ),
          GetPage(
            name: MISSION_HOME,
            page: () => MissionHome(),
          ),
          GetPage(
            name: MISSION_INIT,
            page: () => MissionInit(),
          ),
          GetPage(
            name: ANNOUNCEMENT_SCREEN,
            page: () => Announcements(),
          ),
          GetPage(
            name: LEADERBOARDS_SCREEN,
            page: () => Leaderboards(),
          ),
          GetPage(
            name: VIEW_LEADERBOARD,
            page: () => Leaderboard(),
          ),
          GetPage(
            name: MERCHANT_PANEL,
            page: () => MerchantPanel(),
          ),
          GetPage(
            name: MENTOR_PANEL,
            page: () => MentorPanel(),
          ),
          GetPage(
            name: PEOPLE_LIST_SCREEN,
            page: () => PeopleList(),
          ),
          GetPage(
            name: SEARCH_FRIENDS_SCREEN,
            page: () => SearchUsers(),
          ),
          GetPage(
            name: MY_ACCOUNT,
            page: () => MyAccount(),
          ),
          GetPage(
            name: TRANSFER_SCREEN,
            page: () => TransferCredit(),
          ),
          GetPage(
            name: SETTINGS_SCREEN,
            page: () => Settings(),
          ),
          GetPage(
            name: PINCODE_CHANGE_SETTINGS_SCREEN,
            page: () => ChangePinCode(),
          ),
          GetPage(
            name: PASSWORD_CHANGE_SETTINGS_SCREEN,
            page: () => ChangePassword(),
          ),
          // GetPage(
          //   name: WATCH_AND_EARN,
          //   page: () => WatchAndEarn(),
          // ),
          GetPage(
            name: VIEW_IMAGE,
            page: () => ViewImage(),
          ),
          GetPage(
            name: VIEW_HTML,
            page: () => ViewHtml(),
          ),
          GetPage(
            name: LOGOUT,
            page: () => Logout(),
          ),
        ],
        theme: ThemeData(
          primaryColor: Colors.blue[900],
          secondaryHeaderColor: Colors.deepOrangeAccent,
        ),
        initialRoute: SPLASH_SCREEN,
      ),
    );
  }
}
