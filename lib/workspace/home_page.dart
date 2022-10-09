// ignore_for_file: prefer_interpolation_to_compose_strings
/*
import 'dart:async';
import 'dart:math';

import 'package:dy_rou/services/theme_services.dart';
import 'package:dy_rou/services/time_services.dart';
import 'package:dy_rou/workspace/clock_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
   /*
    @override
  void initstate()
  {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {

       });
     });
     super.initState();
  }
  */
  
  @override
  Widget build(BuildContext context) {
    String s = TimeNow().TimeState();
    var scrHeight=MediaQuery.of(context).size.height;
    
 
    return Scaffold(
    
      appBar: _appBar(context),
      body: Column(
        //alignment: Alignment.center,
        
          children: [Column(children: [
           TimeBox(),
           
          
           LineClockView(),
          ]),
          ]
        ),
        //color: Colors.greenAccent,
    );
  }
}
var tapper=1;
_appBar(BuildContext context)
{
  return AppBar(
    leading: GestureDetector(
      onTap: (){
        ThemeServices().switchTheme();
        String s = TimeNow().TimeState();
        print("Time is "+s);
        print("tapped :)");
        print(DateTime.now().second);
      },
      child: Icon(Icons.nightlight_round,
      size: 20,),
    ),
    toolbarHeight: MediaQuery.of(context).size.height*0.06 ,
    actions: [
    Icon(Icons.person,
      size: 20,),
      SizedBox(width: 20,),
    ],
  );
}
*/


