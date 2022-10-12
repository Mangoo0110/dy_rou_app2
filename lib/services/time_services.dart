//import 'package:flutter/material.dart';
//import 'local_t'
import 'dart:async';

import 'package:flutter/material.dart';
 

class TimeNow{

  
  String TimeState(){
      var st="";
      var dateTime = DateTime.now();
      if(dateTime.hour>=5 && dateTime.hour<=10){
        st="Good Morning";
      }
      else if( (dateTime.hour>= 19 && dateTime.hour<=23)|| (dateTime.hour>=0) && (dateTime.hour<=4) ){
        st="Good Night";
      }
      else{
        st="Have a Good Day";
      }
      //print(st);
      return st;
  }
}

class TimeBox extends StatefulWidget {
  //TimeBox({Key? key}) : super(key: key);
  @override
  State<TimeBox> createState() => _TimeBoxState();
}

class _TimeBoxState extends State<TimeBox> {
 var dateTime = DateTime.now();
  late Timer timer;
  String s= TimeNow().TimeState();

  @override
  void initState() {
    this.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      
      var perviousMinute = DateTime.now().add(Duration(seconds: -1)).minute;
      var currentMinute = DateTime.now().minute;
      
        setState(() {
         dateTime=DateTime.now();
         s= TimeNow().TimeState();
         //print(dateTime.second);
        });
    });
    super.initState();
  }

  @override
  void dispose() {
    this.timer.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
     var scrHeight=MediaQuery.of(context).size.height;
     var scrWidth=MediaQuery.of(context).size.width;
    var timeBoxHeight=scrHeight *(.10);
    dateTime = DateTime.now();
    
    String period="am";
    var hr=dateTime.hour;
    var mn=dateTime.minute;
    var sec=dateTime.second;
    if(hr>=12)
    {
      hr-=12;
      period="pm";
    }

    //print(period+dateTime.second.toString());
    return Container(
      child:   Center(
             child: SingleChildScrollView(
               child: Row(
                 children: [

                   Padding(
                     padding: EdgeInsets.fromLTRB(scrWidth*.04,scrHeight*.01 , scrWidth*.01,scrHeight*.01),
                     child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            new Text(" "+s,
                     style: TextStyle(
                            fontSize: scrWidth*0.4*0.1,
                     ),
                     ),
                     new Text(hr.toString() +":"+ mn.toString() +":"+ sec.toString()+" "+period,
                     style: TextStyle(
                            fontSize: scrWidth*0.4*0.1,
                     ),
                     ),
                          ],
                        ),
                      ),
                     height: timeBoxHeight,
                     width: MediaQuery.of(context).size.width*.5,
                     ),
                   ),
             
                    InkWell(
                      onTap: () {
                        
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(scrWidth*.01, scrHeight*.01, scrWidth*.01,scrHeight*.01),
                        child: Container(
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: new Text( "Add Task",
                                       style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width*.5*.06,
                                       ),
                                       ),
                        ),  
                                       height: timeBoxHeight,
                                       width: MediaQuery.of(context).size.width*.4,
                                       ),
                      ),
                    ),
                 ],
               ),
             ),
           ),
    );
  }


}