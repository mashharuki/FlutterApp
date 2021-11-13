/**
 * メインファイル
 */

import 'package:flutter/material.dart';

// main関数
void main() {
  runApp(const MyApp());
}

/**
 *  MyAppクラス
 *  (起動画面)
 */
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

/**
 * MyHomePageクラス
 * (表示が変換する画面)
 */
class MyHomePage extends StatefulWidget {

  const MyHomePage({Key? key, required this.title}) : super(key: key);
  // タイトル
  final String title;

  // MyHomePageクラスを作り出す関数
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/**
 * _MyHomePageStateクラス
 */
class _MyHomePageState extends State<MyHomePage> {
  // カウンター
  int _counter = 0;

  // 加算関数
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  /**
   * 画面構造のレイアウトを定義するWidget
   */
  @override
  Widget build(BuildContext context) {
    // アプリ全体の構造を定義する。
    return Scaffold(
      // 画面上部のバーを定義する部分
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // 主要のコンテンツを定義する部分
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      // ボタンを表示する。
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
