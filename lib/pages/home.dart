import 'package:anki_tool/pages/tabs/about.dart';
import 'package:anki_tool/pages/tabs/anki_read.dart';
import 'package:flutter/material.dart';

typedef OnTapDrawerItem = void Function(TabType type);

class HomePage extends StatefulWidget {
    const HomePage();

    @override
    _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

    TabType tabType;

    @override
    void initState() {
        super.initState();
        tabType = TabType.About;
    }

    @override
    void dispose() {
        super.dispose();
    }

    void _onTapDrawerItem(TabType type) {
        tabType = type;
        setState(() {});
    }

    @override
    Widget build(BuildContext context) {

        Widget contentView;
        String title;
        switch(tabType){
            case TabType.AnkiRead:
                contentView = AnkiRead();
                title = '汉字转拼音';
                break;
            case TabType.About:
            default:
                contentView = About();
                title = '关于';
        }


        return Scaffold(
            appBar: AppBar(
                title: Text(title),
            ),
            body: SafeArea(
                child: contentView,
            ),
            drawer: Drawer(
                child: _DrawView(this._onTapDrawerItem)
            ),
        );
    }
}

enum TabType {
    About,
    AnkiRead
}

class _DrawView extends StatelessWidget {

    final OnTapDrawerItem _onTapDrawerItem;

    _DrawView(this._onTapDrawerItem);

    @override
    Widget build(BuildContext context) {
        return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
            ),
            child: ListView(
                padding: EdgeInsets.zero,
                children: [
                    DrawerHeader(
                        child: Container(
                            width: 20,
                            height: 20,
                            child: Image.asset(
                                'assets/logo.png',
                            ),
                        ),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                        ),
                    ),
                    ListTile(
                        leading: Icon(Icons.pie_chart, color: Colors.white,),
                        title: Text(
                            '关于',
                            style: TextStyle(
                                fontSize: 18
                            ),
                        ),
                        onTap: (){
                            _onTapDrawerItem(TabType.About);
                            Navigator.pop(context);
                        },
                    ),
                    ListTile(
                        leading: Icon(Icons.tab,color: Colors.white,),
                        title: Text(
                            '汉字转拼音',
                            style: TextStyle(
                                fontSize: 18
                            )
                        ),
                        onTap: (){
                            _onTapDrawerItem(TabType.AnkiRead);
                            Navigator.pop(context);
                        },
                    )
                ],
            ),
        );
    }

}