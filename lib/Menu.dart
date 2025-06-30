import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart'as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:qedic/LoginActivity.dart';
import 'package:qedic/apis/app_exception.dart';
import 'package:qedic/reports/AddReports.dart';
import 'package:qedic/reports/Reports.dart';
import 'package:qedic/utility/Commons.dart';
import 'package:qedic/utility/HexColor.dart';

import 'ChangePasswordActivity.dart';
import 'Leaves/AllLeaves.dart';
import 'NotificationActivity.dart';
import 'UpdateProfile.dart';
import 'holiday/HolidayCalendar.dart';
import 'model/LoginModel.dart';

class Menu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Menu();
}

class _Menu extends State<Menu> {
  @override
  void initState() {
    _updateProfile();
    super.initState();
  }
  LoginModel? loginModel;
  String picture="";
  String namef="";
  String namel="";
  String email="";
  String mobile="";
  _updateProfile()  async {
      loginModel = await Commons.getuser_info();
    setState(()  {
      picture=loginModel!.data!.picture??"";
      namef=loginModel!.data!.firstName??"";
      namel=loginModel!.data!.lastName??"";
      email=loginModel!.data!.email??"";
      mobile=loginModel!.data!.mobile??"";
    });

  }


  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //     statusBarColor: HexColor(HexColor.white),
    //     statusBarIconBrightness: Brightness.dark));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoaderOverlay(
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: AppBar(
                title:Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 10, bottom: 5),
                      child: Stack(
                        children: [
                          Container(
                            height: 50,
                            child:
                            Container(
                              child:  Image(
                                  height: 80,
                                  width: 80,
                                  color: Colors.white,
                                  image: AssetImage('images/q_logo.png')),
                            ),

                            // ,
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 10),
                            child: Container(
                              child: Text("Menu",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: HexColor(HexColor.white),
                                    fontFamily: 'montserrat_bold',
                                    decoration: TextDecoration.none,
                                  )),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
                backgroundColor: HexColor(HexColor.primary_s),
                elevation: 0,
                automaticallyImplyLeading: false,
                systemOverlayStyle: SystemUiOverlayStyle(
                  // Status bar color
                  statusBarColor: HexColor(HexColor.primary_s),
                  // Status bar brightness (optional)
                  statusBarIconBrightness: Brightness.light,
                  // For Android (dark icons)
                  statusBarBrightness: Brightness.light, // For iOS (dark icons)
                ),
              ),
            ),
            body: ListView(children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(shape: BoxShape.rectangle),
                    child: SvgPicture.asset(
                      "images/profile_background.svg",
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.fill,
                      color: HexColor(HexColor.primary_s),
                    ),
                  ),
                  Container(
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.topCenter,
                          margin: EdgeInsets.only(top: 15, left: 20),
                          child:  CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                                picture),
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.topCenter,
                              margin: EdgeInsets.only(
                                top: 15,
                                left: 10,
                              ),
                              child: Text("${namef} ${namel}",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: HexColor(HexColor.white),
                                    fontFamily: 'montserrat_medium',
                                    decoration: TextDecoration.none,
                                  )),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: 10,
                              ),
                              alignment: Alignment.topCenter,
                              child: Text(email,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: HexColor(HexColor.white),
                                    fontFamily: 'montserrat_regular',
                                    decoration: TextDecoration.none,
                                  )),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: 10,
                              ),
                              alignment: Alignment.topCenter,
                              child: Text(mobile,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: HexColor(HexColor.white),
                                    fontFamily: 'montserrat_regular',
                                    decoration: TextDecoration.none,
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: HexColor(HexColor.primary_s).withOpacity(0.2),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return UpdateProfile();
                        })).then((value) => _updateProfile());

                  },
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: HexColor(HexColor.primary_s).withOpacity(0.4),
                        ),
                        child: SvgPicture.asset(
                          "images/update_profile.svg",
                          height: 24,
                          width: 24,
                          fit: BoxFit.fill,
                          color: HexColor(HexColor.primary_s),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 15),
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 14,
                            color: HexColor(HexColor.primary_s),
                            fontFamily: 'lato_bold',
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: HexColor(HexColor.primary_s).withOpacity(0.2),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return ChangePasswordActivity();
                        }));
                  },
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(10)),
                          color: HexColor(HexColor.primary_s).withOpacity(0.4),
                        ),
                        child: SvgPicture.asset(
                          "images/password.svg",
                          height: 24,
                          width: 24,
                          fit: BoxFit.fill,
                          color: HexColor(HexColor.primary_s),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 15),
                        child: Text(
                          "Change Password",
                          style: TextStyle(
                            fontSize: 14,
                            color: HexColor(HexColor.primary_s),
                            fontFamily: 'lato_bold',
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: HexColor(HexColor.primary_s).withOpacity(0.2),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return NotificationActivity();
                        })).then((value) {
                      setState(() {
                      });
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: HexColor(HexColor.primary_s).withOpacity(0.4),
                        ),
                        child: SvgPicture.asset(
                          "images/noticeboard.svg",
                          height: 24,
                          width: 24,
                          fit: BoxFit.fill,
                          color: HexColor(HexColor.primary_s),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 15),
                        child: Text(
                          "Noticeboard",
                          style: TextStyle(
                            fontSize: 14,
                            color: HexColor(HexColor.primary_s),
                            fontFamily: 'lato_bold',
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: HexColor(HexColor.primary_s).withOpacity(0.2),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Reports();
                    })).then((value) {});
                  },
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: HexColor(HexColor.primary_s).withOpacity(0.4),
                        ),
                        child: SvgPicture.asset(
                          "images/noticeboard.svg",
                          height: 24,
                          width: 24,
                          fit: BoxFit.fill,
                          color: HexColor(HexColor.primary_s),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 15),
                        child: Text(
                          "Reports",
                          style: TextStyle(
                            fontSize: 14,
                            color: HexColor(HexColor.primary_s),
                            fontFamily: 'lato_bold',
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: HexColor(HexColor.primary_s).withOpacity(0.2),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return HolidayCalendar();
                        })).then((value) {
                      setState(() {

                      });
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: HexColor(HexColor.primary_s).withOpacity(0.4),
                        ),
                        child:  SvgPicture.asset(
                          "images/ic_holidays.svg",
                          height: 24,
                          width: 24,
                          fit: BoxFit.fill,
                          color: HexColor(HexColor.primary_s),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 15),
                        child: Text(
                          "Holiday List",
                          style: TextStyle(
                            fontSize: 14,
                            color: HexColor(HexColor.primary_s),
                            fontFamily: 'lato_bold',
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: HexColor(HexColor.primary_s).withOpacity(0.2),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return AllLeaves();
                        })).then((value) {
                      setState(() {
                      });
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: HexColor(HexColor.primary_s).withOpacity(0.4),
                        ),
                        child: SvgPicture.asset(
                          "images/ic_leave.svg",
                          height: 24,
                          width: 24,
                          fit: BoxFit.fill,
                          color: HexColor(HexColor.primary_s),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 15),
                        child: Text(
                          "Apply Leave",
                          style: TextStyle(
                            fontSize: 14,
                            color: HexColor(HexColor.primary_s),
                            fontFamily: 'lato_bold',
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: HexColor(HexColor.primary_s).withOpacity(0.2),
                ),
                child: InkWell(
                  onTap: () {
                    showGeneralDialog(
                      barrierLabel: "Label",
                      barrierDismissible: true,
                      barrierColor: Colors.black.withOpacity(0.5),
                      transitionDuration: Duration(milliseconds: 700),
                      context: context,
                      pageBuilder: (context, anim1, anim2) {
                        return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7)),
                            child: Container(
                              height: 320,
                              width: MediaQuery.of(context).size.width,
                              margin:
                                  EdgeInsets.only(bottom: 0, left: 0, right: 0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: SizedBox.expand(
                                  child: Column(children: <Widget>[
                                Container(
                                    decoration: BoxDecoration(
                                      color: HexColor(HexColor.primary_s),
                                      borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(7),
                                          topLeft: Radius.circular(7)),
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.all(10.0),
                                    child: Text("Confirmation",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontFamily: 'montserrat_medium',
                                          decoration: TextDecoration.none,
                                        ))),
                                Container(
                                  margin:  EdgeInsets.only(
                                      top: 20.0, left: 20, right: 20),
                                  child:  Image(
                                    height: 100,
                                    width: 200,
                                    alignment: Alignment.center,
                                    color: HexColor(HexColor.primary_s),

                                    image: AssetImage(

                                      'images/q_logo.png',
                                    ),
                                  ),
                                ),
                                Container(
                                    margin: const EdgeInsets.only(
                                        top: 10.0, left: 20, right: 20),
                                    child: Center(
                                      child: Text("Are you sure want to logout?",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                HexColor(HexColor.primarycolor),
                                            fontFamily: 'montserrat_regular',
                                            decoration: TextDecoration.none,
                                          )),
                                    )),
                                Container(
                                  margin: const EdgeInsets.only(top: 50),
                                  child: ListTile(
                                    title: Row(
                                      children: <Widget>[
                                        Expanded(
                                            child: Container(
                                                margin: const EdgeInsets.only(
                                                    left: 20, right: 20),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    foregroundColor: HexColor(HexColor.white), backgroundColor: HexColor(
                                                        HexColor.primary_s),
                                                    shadowColor:
                                                        HexColor(HexColor.gray),
                                                    elevation: 3,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                32.0)),
                                                    minimumSize: Size(
                                                        100, 40), //////// HERE
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    LogoutAPI();
                                                  },
                                                  child: Text("Yes"),
                                                ))),
                                        Expanded(
                                            child: Container(
                                                margin: const EdgeInsets.only(
                                                    left: 20, right: 20),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    foregroundColor: HexColor(HexColor.white), backgroundColor: HexColor(
                                                        HexColor.primary_s),
                                                    shadowColor:
                                                        HexColor(HexColor.gray),
                                                    elevation: 3,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                32.0)),
                                                    minimumSize: Size(
                                                        100, 40), //////// HERE
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("No"),
                                                ))),
                                      ],
                                    ),
                                  ),
                                )
                              ])),
                            ));
                      },
                      transitionBuilder: (context, anim1, anim2, child) {
                        return SlideTransition(
                          position: Tween(begin: Offset(0, 1), end: Offset(0, 0))
                              .animate(anim1),
                          child: child,
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: HexColor(HexColor.primary_s).withOpacity(0.4),
                        ),
                        child: ImageIcon(
                           AssetImage("images/logout.png"),
                          color: HexColor(HexColor.primary_s),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 15),
                        child: Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 14,
                            color: HexColor(HexColor.primary_s),
                            fontFamily: 'lato_bold',
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container( width: double.infinity,
                margin: EdgeInsets.only(left: 20, right: 20,top: 10, bottom: 20),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: HexColor(HexColor.primary_s).withOpacity(0.2),
                ),
      child: InkWell(
        onTap: () {
          showGeneralDialog(
                      barrierLabel: "Label",
                      barrierDismissible: true,
                      barrierColor: Colors.black.withOpacity(0.5),
                      transitionDuration: Duration(milliseconds: 700),
                      context: context,
                      pageBuilder: (context, anim1, anim2) {
                        return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7)),
                            child: Container(
                              height: 340,
                              width: MediaQuery.of(context).size.width,
                              margin:
                                  EdgeInsets.only(bottom: 0, left: 0, right: 0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: SizedBox.expand(
                                  child: Column(children: <Widget>[
                                Container(
                                    decoration: BoxDecoration(
                                      color: HexColor(HexColor.primary_s),
                                      borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(7),
                                          topLeft: Radius.circular(7)),
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.all(10.0),
                                    child: Text("Confirmation",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontFamily: 'montserrat_medium',
                                          decoration: TextDecoration.none,
                                        ))),
                                Container(
                                  margin:  EdgeInsets.only(
                                      top: 20.0, left: 20, right: 20),
                                  child:  Image(
                                    height: 80,
                                    width: 200,
                                    alignment: Alignment.center,
                                    color: HexColor(HexColor.primary_s),

                                    image: AssetImage(
                                      'images/q_logo.png',
                                    ),
                                  ),
                                ),
                                Container(
                                    margin: const EdgeInsets.only(
                                        top: 10.0, left: 20, right: 20),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Text("Are you sure want to Delete Account?",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color:
                                                    HexColor(HexColor.primarycolor),
                                                fontFamily: 'montserrat_regular',
                                                decoration: TextDecoration.none,
                                              )),
                                          Text('If you delete your account, all your data will be permanently erased and cannot be recovered.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    HexColor(HexColor.primarycolor),
                                                fontFamily: 'montserrat_regular',
                                                decoration: TextDecoration.none,
                                              )),
                                        ],
                                      ),
                                    )),
                                Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  child: ListTile(
                                    title: Row(
                                      children: <Widget>[
                                        Expanded(
                                            child: Container(
                                                margin: const EdgeInsets.only(
                                                    left: 20, right: 20),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    foregroundColor: HexColor(HexColor.white), backgroundColor: HexColor(
                                                        HexColor.primary_s),
                                                    shadowColor:
                                                        HexColor(HexColor.gray),
                                                    elevation: 3,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                32.0)),
                                                    minimumSize: Size(
                                                        100, 40), //////// HERE
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    LogoutAPI();
                                                  },
                                                  child: Text("Yes"),
                                                ))),
                                        Expanded(
                                            child: Container(
                                                margin: const EdgeInsets.only(
                                                    left: 20, right: 20),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    foregroundColor: HexColor(HexColor.white), backgroundColor: HexColor(
                                                        HexColor.primary_s),
                                                    shadowColor:
                                                        HexColor(HexColor.gray),
                                                    elevation: 3,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                32.0)),
                                                    minimumSize: Size(
                                                        100, 40), //////// HERE
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("No"),
                                                ))),
                                      ],
                                    ),
                                  ),
                                )
                              ])),
                            ));
                      },
                      transitionBuilder: (context, anim1, anim2, child) {
                        return SlideTransition(
                          position: Tween(begin: Offset(0, 1), end: Offset(0, 0))
                              .animate(anim1),
                          child: child,
                        );
                      },
                    );
                  },
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              margin: EdgeInsets.symmetric(horizontal: 5),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:  HexColor(HexColor.primary_s).withOpacity(0.4)),
              child: Icon(Icons.delete_forever, color:  HexColor(HexColor.primary_s)),
            ),
            SizedBox(width: 15),
            Text(
              "Delete Account",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontFamily: 'lato_bold'),
            ),
          ],
        ),
      ),
    ), 
            ])),
      ),
    );
  }

  LogoutAPI() async {

    Commons.saveuser_info("");
    Commons.saveloginstatus(false);

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return LoginActivity();
    }));


    // context.loaderOverlay.show();
    //
    // try {
    //   //create multipart request for POST or PATCH method
    //   var request = http.MultipartRequest("POST", Uri.parse(Commons.loginapi));
    //   //add text fields
    //   request.fields["email"] = userid_Controller.text;
    //   request.fields["password"] = paswordController.text;
    //   request.fields["device_type"] = Platform.isAndroid?"Android":"iOS";
    //
    //
    //   var sendresponse = await request.send();
    //
    //   //Get the response from the server
    //   var responseData = await sendresponse.stream.toBytes();
    //   var response = String.fromCharCodes(responseData);
    //
    //   context.loaderOverlay.hide();
    //   print('sarjeet log  ${response}');
    //   if (response == null ||
    //       response.contains("A PHP Error was encountered") ||
    //       response.contains("<div") ||
    //       response.contains("</html")) {
    //     Commons.flushbar_Messege(context, "internal server Error ");
    //   } else {
    //
    //     Commons.saveuser_info(response);
    //     Commons.saveloginstatus(true);
    //
    //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
    //       return HomeActivity();
    //     }));
    //
    //
    //   }
    // } on SocketException {
    //   context.loaderOverlay.hide();
    //   Commons.flushbar_Messege(context, "No Internet Connection");
    //   throw FetchDataException('No Internet Connection');
    // }


  }


  deleteAPI() async {


    context.loaderOverlay.show();
    
    try {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(Commons.deleteAccount));
      //add text fields
     
      request.fields["user_id"] = "${loginModel?.data!.id ??""}";
    
    
      var sendresponse = await request.send();
    
      //Get the response from the server
      var responseData = await sendresponse.stream.toBytes();
      var response = String.fromCharCodes(responseData);
    
      context.loaderOverlay.hide();
      print('sarjeet log  ${response}');
      if (response == null ||
          response.contains("A PHP Error was encountered") ||
          response.contains("<div") ||
          response.contains("</html")) {
        Commons.flushbar_Messege(context, "internal server Error ");
      } else {
    
       
    Commons.saveuser_info("");
    Commons.saveloginstatus(false);

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return LoginActivity();
    }));

    
    
      }
    } on SocketException {
      context.loaderOverlay.hide();
      Commons.flushbar_Messege(context, "No Internet Connection");
      throw FetchDataException('No Internet Connection');
    }


  }

}





