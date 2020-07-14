import 'package:anki_tool/utils/adaptive.dart';
import 'package:flutter/material.dart';

class About extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        final isDesktop = isDisplayDesktop(context);

        return SingleChildScrollView(
            child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                    width: isDesktop ? 600 : double.infinity,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                                _RuleView(),
                            ],
                        ),
                    )
                ),
            )
        );
    }
}

class _RuleView extends StatelessWidget {

    _RuleView();

    final String rule = '''
诗的要求：
1. 背
2. 每句含义
3. 看拼音默写

阅读：
1. 读一遍，标记不会认的字，添加拼音
2. 添加到"我会认里"

写日记：
1. 写日记时，不会写的字写拼音
2. 不会写的汉字记录到"我会写里"
    ''';

    @override
    Widget build(BuildContext context) {
        return Card(
            color: Color(0x03FEFEFE),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(rule),
            )
        );
    }

}