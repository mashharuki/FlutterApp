/**
 * ログイン状態を確認するためのファイル
 */

import 'package:flutter/material.dart';
import 'list.dart';
import 'splash.dart';
import 'user_auth.dart';

/**
 * Initializeクラス
 */
class Initialize extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _mailLoginCheck(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Text("接続に失敗しました。");
          } else if (snapshot.connectionState == ConnectionState.done) {
            return List();
          } else {
            return Splash();
          }
        }
      ),
    );
  }

  /**
   * メールによるログインが確認する関数
   */
  Future _mailLoginCheck() async {
    if (userAuth.currentUser == null) {
      await userAuth.signInAnonymously();
    }
  }
}