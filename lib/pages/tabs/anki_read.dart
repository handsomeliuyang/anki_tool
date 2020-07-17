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

const COMMON_WORD = {
    '好': 'hǎo',
    '的': 'de',
    '大': 'dà',
    '王': 'wáng',
    '南': 'nán',
    '风': 'fēng',
    '将': 'jiāng',
    '北': 'běi',
    '了': 'le',
    '上': 'shàng',
    '看': 'kàn',
    '见': 'jiàn',
    '有': 'yǒu',
    '许': 'xǔ',
    '都': 'dōu',
    '干': 'gàn',
    '打': 'dǎ',
    '蛤': 'gé',
    '悄': 'qiāo',
    '地': 'de',
    '过': 'guò',
    '没': 'méi',
    '吓': 'xià',
    '得': 'de',
    '那': 'nà',
    '处': 'chù',
    '些': 'xiē',
    '这':'zhè',
    '从':'cóng',
    '传':'chuán',
    '个':'gè',
    '着':'zhe',
    '正': 'zhèng',
    '中': 'zhōng',
    '解': 'jiě',
    '台': 'tái',
    '称': 'chēng',
    '为': 'wéi',
    '提': 'tí',
    '别': 'bié',
    '远': 'yuǎn',
    '只': 'zhǐ',
    '石': 'shí',
    '约': 'yuē',
    '尺': 'chǐ',
    '说': 'shuō',
    '父': 'fù',
    '要': 'yào',
    '呀': 'yā',
    '吧': 'bā',
    '服': 'fú',
    '内': 'nèi',
    '可':'kě',
    '不': 'bù',
    '语': 'yǔ',
    '头':'tóu',
    '兴':'xìng',
    '便':'biàn',
    '空':'kōng',
    '孙':'sūn',
    '各':'gè',
    '并':'bìng',
    '给':'gěi',
    '间':'jiān',
    '识':'shí',
    '扫':'sǎo',
    '挑':'tiāo',
    '与':'yǔ',
    '同':'tóng',
    '亲':'qīn',
    '亡':'wáng',
    '觉':'jué',
    '把':'bǎ',
    '重':'chóng',
    '拾':'shí',
    '量':'liàng',
    '她':'tā',
    '被':'bèi',
};

class _AnkiReadState extends State<AnkiRead> {

    List<_WordData> words = [];
    Set<String> multiWords = Set();
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

        this.words.clear();
        this.multiWords.clear();

        for(int i=0; i<content.length; i++) {
            var char = content[i];

            if(char == ' '){
                continue ;
            }

            _WordData wordData = _WordData(
                word: char,
                pinyins: PinyinHelper.convertToPinyinArray(char, PinyinFormat.WITH_TONE_MARK)
            );

            this.words.add(wordData);
            if(wordData.pinyins.length > 1) {
                multiWords.add('${wordData.word}=${wordData.pinyins.join(',')}');

                String commonPinyin = COMMON_WORD[wordData.word];
                if(commonPinyin != null && commonPinyin.length>0) {
                    wordData.pinyins.clear();
                    wordData.pinyins.add(commonPinyin);
                }
            }
        }
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
                                const SizedBox(height: 8,),
                                _MultiPinyinShowView(this.multiWords),
                                const SizedBox(height: 8,),
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
        String pinyins = words.map((item) {
                if(item.pinyins.length == 0) {
                    return item.word;
                }
                return item.pinyins.join(',');
            })
            .join(' ');

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
                                    child: Text('复制拼音'),
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

class _MultiPinyinShowView extends StatelessWidget {

    final Set<String> multiWords;

    _MultiPinyinShowView(this.multiWords);

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

        String pinyins = multiWords.join(' ');

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
                                    child: Text('复制多音字'),
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
            .toSet()
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
        String htmlTableAndStyle = style + '\n' + htmlTable;

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
                                                ClipboardData(text: htmlTableAndStyle))
                                                .then((dynamic result)=>_showSnackBarOnCopySuccess(context, result))
                                                .catchError((dynamic result)=>_showSnackBarOnCopyFailure(context, result));
                                        },
                                        child: Text('全部复制'),
                                    ),
                                    const SizedBox(width: 12,),
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
                                        child: Text('复制表格'),
                                    ),
                                ],
                            ),
                            HighlightView(
                                htmlTableAndStyle,
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

    static const style = '''
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
    ''';

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
