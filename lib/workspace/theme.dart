import 'package:flutter/material.dart';

class Themes{
static final light= ThemeData(
        appBarTheme: AppBarTheme(color: Colors.amber)
      );

static final dark= ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme(color: Colors.blueGrey),
       // brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black
      );
} 