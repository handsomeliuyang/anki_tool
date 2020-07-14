import 'package:anki_tool/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
        final base = ThemeData.dark();
        return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
                appBarTheme: const AppBarTheme(brightness: Brightness.dark, elevation: 0),
                scaffoldBackgroundColor: Color(0xFF33333D),
                primaryColor: Color(0xFF33333D),
                focusColor: Color(0xCCFFFFFF),
                textTheme: _buildRallyTextTheme(base.textTheme),
                inputDecorationTheme: const InputDecorationTheme(
                    labelStyle: TextStyle(
                        color: Color(0xFFD8D8D8),
                        fontWeight: FontWeight.w500
                    ),
                    hintStyle: TextStyle(
                        color: Color(0xFFD8D8D8),
                        fontWeight: FontWeight.w500
                    ),
                    filled: true,
                    fillColor: Color(0xFF26282F),
                    focusedBorder: InputBorder.none
                )
            ),
            initialRoute: '/',
            routes: RouteConfig.paths,
        );
    }

    TextTheme _buildRallyTextTheme(TextTheme base) {
        return base
            .copyWith(
            bodyText2: GoogleFonts.robotoCondensed(
                fontSize: 14,
                fontWeight: FontWeight.w400,
            ),
            bodyText1: GoogleFonts.eczar(
                fontSize: 40,
                fontWeight: FontWeight.w400,
            ),
            button: GoogleFonts.robotoCondensed(
                fontWeight: FontWeight.w700,
            ),
            headline5: GoogleFonts.eczar(
                fontSize: 40,
                fontWeight: FontWeight.w600,
            ),
        )
            .apply(
            displayColor: Colors.white,
            bodyColor: Colors.white,
        );
    }
}
