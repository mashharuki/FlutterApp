/**
 * 簡易スプラッシュ画面用のファイル
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/**
 * Splashクラス
 */
class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const Text("スプラッシュ画面"),
      ),
    );
  }
}