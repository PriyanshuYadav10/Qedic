import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';


import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:intl/date_symbol_data_local.dart';

import '../utility/Commons.dart';
import '../utility/HexColor.dart';

class ProfileActivity extends StatefulWidget {
  // Initially password is obscure
  @override
  State<ProfileActivity> createState() => _ProfileActivityState();
}

class _ProfileActivityState extends State<ProfileActivity> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: SafeArea(
            child: Scaffold(
                appBar: Commons.Appbar_logo(true, context, "Add Expenses"),
                body: LoaderOverlay(
                  child: SingleChildScrollView(
                      child: Column(children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              // Set border width
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0)), // Set rounded corner radius
                              boxShadow: [BoxShadow(blurRadius: 1,color: Colors.grey,offset: Offset(0,0))] // Make rounded corner of border
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Container(
                                margin: EdgeInsets.only(top: 15),
                                child: TextField(
                                  style: TextStyle(color: HexColor(HexColor.primary_s)),
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.add_road_outlined,
                                        color: HexColor(HexColor.primary_s),
                                      ),
                                      border: OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: HexColor(HexColor.gray_light))),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: HexColor(HexColor.gray_light))),
                                      filled: true,
                                      hintText: "Enter Mileage km",
                                      fillColor: HexColor(HexColor.gray_light)),
                                ),
                              ),

                              Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: HexColor(
                                              HexColor.primarycolor))),
                                  child: Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 50,
                                    color: HexColor(HexColor.primarycolor),
                                  ))

                            ],),
                        ),

                        Container(
                          margin: const EdgeInsets.only(top: 30.0, left: 20.0, bottom: 30,right: 20),
                          height: 50.0,
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: HexColor(HexColor.primary_s)),
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: HexColor(HexColor.white),
                                  fontFamily: 'lato_bold',
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              onPressed: () {

                              }
                          ),
                        ),
                      ],)),
                ))));
  }

}
