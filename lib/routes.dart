import 'package:anki_tool/pages/home.dart';
import 'package:anki_tool/pages/login.dart';
import 'package:flutter/cupertino.dart';

class RouteConfig {
    static const String homeRoute = '/';
    static const String loginRoute = '/login';

    static Map<String, WidgetBuilder> paths = {
        homeRoute: (BuildContext context) => const HomePage(),
        loginRoute: (BuildContext context) => const LoginPage()
    };
}