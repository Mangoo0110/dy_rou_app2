import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:dy_rou/services/time_services.dart';
import 'package:dy_rou/workspace/home_page.dart';
import 'package:flutter/material.dart';

int counter=0;
int loader=1;
bool yes=false;
bool _isInitialValue =true;
class LineClockView extends StatefulWidget {
  LineClockView({Key? key}) : super(key: key);
  
  @override
  State<LineClockView> createState() => _LineClockViewState();
}
/*
var dayToMillisecond=24*60*60;//10millisecond
  late Timer timer;
  var dateTime=DateTime.now();
  var passedMilliseconds=DateTime.now().hour*60*60 + DateTime.now().minute*60+DateTime.now().second;
 */
class _LineClockViewState extends State<LineClockView> {
  
  var dateTime = DateTime.now();
  late Timer timer;
  String s= TimeNow().TimeState();
  //var animationTime=1;
  var dayTosecond=24*60*60;//1 hour
 

  @override
  void initState() {
    counter=0;
    
    this.timer = Timer.periodic( const Duration(seconds:1), (timer) {
      
      counter+=1;
       print("Counter=$counter");
      counter%=(24*60*60);
      if(counter==1)
      {
       
        print("////");
        
       setState(() {
        dateTime=DateTime.now();
        //final random= Random();
       });
      }
      else if(counter==2)
      {
         setState(() {
        //loader=1;
        dateTime=DateTime.now();
        //final random= Random();
       });
      }
     
      
    });
 
    super.initState();
   // });
  }

  @override
  void dispose() {
    this.timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   // print("Loader=$loader");
    final random=Random();
     var hgt= MediaQuery.of(context).size.height;
     var wdt=MediaQuery.of(context).size.width;
     double  pad_ing=0.0;
     pad_ing= max(0.0,MediaQuery.of(context).size.height*(0.01));
     var _height=hgt-hgt*(0.1)-(pad_ing*2)-30-AppBar().preferredSize.height;
     var greyContainerHeight= _height*24;
     var animate=1;
     var heightPerSecond= (greyContainerHeight)/dayTosecond;
     var greenContainerHeight=greyContainerHeight;

     if(counter==1)
       {
        greenContainerHeight=greyContainerHeight-heightPerSecond*(dateTime.hour*60*60+dateTime.minute*60+ dateTime.second);
        animate=1;
       }
     else if(counter==2)
     {
       greenContainerHeight=0;
     animate=(dayTosecond-(dateTime.hour*60*60+dateTime.minute*60+ dateTime.second) );
     counter=dateTime.hour*60*60+dateTime.minute*60+ dateTime.second;
     }
     
     print("greenContainerHeight=$greenContainerHeight");
     
    return Center(
      child: Container(
        
        height: _height,
        width: wdt,
        child: SingleChildScrollView(
          child: Stack(
            children: [
           //   for(int i=0;i<100;i++)
             
                 Container(
                  height: greyContainerHeight,
                  width: wdt,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.green.shade200,
                  ),
                  
                   child: Expanded(
                     child: Align(
                      alignment: Alignment.bottomCenter,
                       child: AnimatedContainer(
                        //transform: _isInitialValue ? Matrix4.identity() : Matrix4.rotationX(45),
                        decoration: BoxDecoration(
                                     borderRadius:BorderRadius.circular(25),// BorderRadius.only(bottomLeft: Radius.circular(25),bottomRight: Radius.circular(25),topLeft: Radius.circular(greenContainerBorderRadius),topRight: Radius.circular(greenContainerBorderRadius)),
                         
                        color: Colors.green.shade300,
                        ),
                         height: greenContainerHeight,
                         width: wdt,
                          duration:  Duration(seconds:animate),
                                     // Provide an optional curve to make the animation feel smoother.
                       curve: Curves.linear,
                                     ),
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