import 'package:anki_tool/utils/adaptive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:lpinyin/lpinyin.dart';

class AnkiRead extends StatefulWidget {

    @override
    _AnkiReadState createState() => _AnkiReadState();

}

class _AnkiReadState extends State<AnkiRead> {

    List<_WordData> words = [];
    int rowNum = 10;

    final rowNumController = TextEditingController();
    final contentController = TextEditingController();
    final mutiPinyinController = TextEditingController();

    @override
    void initState() {
        super.initState();
        rowNumController.text = '10';
    }

    @override
    void dispose() {
        super.dispose();
        rowNumController.dispose();
        contentController.dispose();
        mutiPinyinController.dispose();
    }

    void _genPinyin(){
        final int rowNum = int.parse(rowNumController.text);
        final String content = contentController.text;

        List<_WordData> list = [];
        for(int i=0; i<content.length; i++) {
            var char = content[i];

            if(char == ' '){
                continue ;
            }

            list.add(_WordData(
                word: char,
                pinyins: PinyinHelper.convertToPinyinArray(char, PinyinFormat.WITH_TONE_MARK)
            ));
        }
        this.words = list;
        this.rowNum = rowNum;
        setState(() {});
    }

    void _updateMutilPinyin(){
        if(mutiPinyinController.text == ' '
            || mutiPinyinController.text == ''){
            return ;
        }

        List<_WordData> updateMultiWords = mutiPinyinController.text
            .split('\n')
            .map((item) => item.split('='))
            .map((list) => _WordData(word:list[0], pinyins:list[1].split(',')))
            .toList();

        words = words.map((item) {
            for (_WordData data in updateMultiWords) {
                if (item.word == data.word) {
                    item.pinyins = data.pinyins;
                    break;
                }
            }
            return item;
        }).toList();
        setState(() {});
    }

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
                            children: [
                                _InputView(
                                    rowNumController: this.rowNumController,
                                    contentController: this.contentController,
                                    onTapGenPinyin: this._genPinyin
                                ),
                                const SizedBox(height: 8),
                                _PinyinView(this.words),
                                _MutiPinyinView(
                                    words: this.words,
                                    mutiPinyinController: this.mutiPinyinController,
                                    onTapUpdateMultiPinyin: this._updateMutilPinyin,
                                ),
                                const SizedBox(height: 8),
                                _ResultView(words: words, rowNum: rowNum,)
                            ],
                        ),
                    )
                ),
            )
        );
    }
}

class _InputView extends StatelessWidget {

    final TextEditingController rowNumController;
    final TextEditingController contentController;
    final VoidCallback onTapGenPinyin;

    _InputView({
        this.rowNumController,
        this.contentController,
        this.onTapGenPinyin
    });

    @override
    Widget build(BuildContext context) {
        return Card(
            color: Color(0x03FEFEFE),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        Center(
                            child: Text('输入框')
                        ),
                        const SizedBox(height: 12),
                        Divider(thickness: 1, height: 0, color: Colors.black),
                        const SizedBox(height: 12),

                        TextField(
                            autofocus: true,
                            decoration: InputDecoration(
                                hintText: '默认值为10',
                                labelText: '列数',
                            ),
                            controller: rowNumController,
                        ),
                        const SizedBox(height: 12,),
                        TextField(
                            autofocus: true,
                            decoration: InputDecoration(
//                                hintText: '请输入中文',
                                labelText: '文章'
                            ),
                            controller: contentController,
                        ),
                        const SizedBox(height: 12,),

                        RaisedButton(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(4)),
                            ),
                            onPressed: onTapGenPinyin,
                            child: Text('添加拼音'),
                        ),
                        const SizedBox(height: 12),
                    ],
                ),
            )
        );
    }

}

class _PinyinView extends StatelessWidget {

    final List<_WordData> words;

    _PinyinView(this.words);

    void _showSnackBarOnCopySuccess(BuildContext context, dynamic result) {
        Scaffold.of(context).showSnackBar(
            SnackBar(
                content: Text('拼音复制成功'),
            ),
        );
    }

    void _showSnackBarOnCopyFailure(BuildContext context, Object exception) {
        Scaffold.of(context).showSnackBar(
            SnackBar(
                content: Text('拼音复制失败'),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {

        String pinyins = words.map((item) => item.pinyins.join(',')).join(' ');

        return Card(
            color: Color(0x03FEFEFE),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        Row(
                            children: [
                                RaisedButton(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                    ),
                                    onPressed: () async {
                                        await Clipboard.setData(
                                            ClipboardData(text: pinyins))
                                            .then((dynamic result)=>_showSnackBarOnCopySuccess(context, result))
                                            .catchError((dynamic result)=>_showSnackBarOnCopyFailure(context, result));
                                    },
                                    child: Text('全部复制'),
                                ),
                            ],
                        ),
                        Text(
                            pinyins,
                            style: TextStyle(
                                backgroundColor: Colors.black12,
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}

class _MutiPinyinView extends StatelessWidget {

    final List<_WordData> words;
    final TextEditingController mutiPinyinController;
    final VoidCallback onTapUpdateMultiPinyin;

    _MutiPinyinView({
        this.words,
        this.mutiPinyinController,
        this.onTapUpdateMultiPinyin
    });

    @override
    Widget build(BuildContext context) {

        mutiPinyinController.text = words
            .where((element) => element.pinyins.length > 1)
            .map((wordData) => '${wordData.word}=${wordData.pinyins.join(',')}')
            .toList()
            .join('\n');

        return Card(
            color: Color(0x03FEFEFE),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        TextField(
                            controller: mutiPinyinController,
                            maxLines: 5,
                            autofocus: true,
                        ),
                        const SizedBox(height: 8,),
                        RaisedButton(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(4)),
                            ),
                            onPressed: onTapUpdateMultiPinyin,
                            child: Text('更新多音字'),
                        ),
                    ],
                )

            ),
        );
    }
}

class _ResultView extends StatelessWidget {

    final List<_WordData> words;
    final int rowNum;

    _ResultView({
        this.words,
        this.rowNum
    });

    void _showSnackBarOnCopySuccess(BuildContext context, dynamic result) {
        Scaffold.of(context).showSnackBar(
            SnackBar(
                content: Text('复制成功'),
            ),
        );
    }

    void _showSnackBarOnCopyFailure(BuildContext context, Object exception) {
        Scaffold.of(context).showSnackBar(
            SnackBar(
                content: Text('复制失败'),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {

        String htmlTable = toHtmlTable(words, rowNum);

        return Card(
            color: Color(0x03FEFEFE),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                            Row(
                                children: [
                                    RaisedButton(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4)),
                                        ),
                                        onPressed: () async {
                                            await Clipboard.setData(
                                                ClipboardData(text: htmlTable))
                                                .then((dynamic result)=>_showSnackBarOnCopySuccess(context, result))
                                                .catchError((dynamic result)=>_showSnackBarOnCopyFailure(context, result));
                                        },
                                        child: Text('全部复制'),
                                    ),
                                ],
                            ),
                            HighlightView(
                                htmlTable,
                                language: 'html',
                                theme: githubTheme,
                                padding: const EdgeInsets.all(12),
                                textStyle: TextStyle(
                                    fontFamily: 'My awesome monospace font',
                                    fontSize: 16,
                                ),
                            ),
                        ],
                    ),
                )
            ),
        );
    }

    String toHtmlTable(List<_WordData> words, int rowNum){
        String tableContent = '';
        int rowIndex = 0;
        String pinRow = '';
        String wordRow = '';
        for(_WordData wordData in words){
            if(rowIndex == 0) {
                pinRow = '<tr>\n';
                wordRow = '<tr>\n';
            }

            rowIndex++;
            pinRow = pinRow + '<td class="pinyin">${wordData.pinyins.join(',')}</td>\n';
            wordRow = wordRow + '<td class="word">${wordData.word}<br></td>\n';

            if(rowIndex == rowNum) {
                pinRow = pinRow + '</tr>\n';
                wordRow = wordRow + '</tr>\n';

                tableContent = tableContent + pinRow + wordRow;
                rowIndex = 0;
            }
        }
        if(rowIndex != 0) {
            pinRow = pinRow + '</tr>\n';
            wordRow = wordRow + '</tr>\n';

            tableContent = tableContent + pinRow + wordRow;
        }

        String html = '''
<style>
    table, th, td {
      border: 0px;
    }
    td {
        text-align:center; 
        vertical-align:middle;
      
    }
    
    .pinyin {
        font-size: 14px;
    }
    .word {
        font-size: 22px;
        padding-left: 8px;
        padding-right: 8px;
    }
</style>
<table>
    <tbody>
        ${tableContent}
    </tbody>
</table>
        ''';
        return html;
    }
}

class _WordData {
    String word;
    List<String> pinyins;

    _WordData({
        this.word,
        this.pinyins
    });
}
