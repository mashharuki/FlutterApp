/**
 * リスト一覧用のDartファイル
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'input_form.dart';
import 'user_auth.dart';

/**
 * Listクラス
 */
class List extends StatefulWidget {
  // createState関数
  @override
  _MyList createState() => _MyList();
}

/**
 * _MyListクラス
 */
class _MyList extends State<List> {
  // リスト画面構成
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: const Text("貸し借りメモ"),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                print("ログインボタンが押されました。");
                showBasicDialog(context);
              },
              icon: Icon(Icons.exit_to_app)
          )
        ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users').doc(userAuth.currentUser!.uid)
              .collection('promises').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            if (snapshot.data?.docs.length == 0) return Center(child: Text("データが登録されていません"));
            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              padding: const EdgeInsets.only(top: 10.0),
              itemBuilder: (context, index) => _buildListItem(context, snapshot.data!.docs[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          print("新規作成ボタンが押されました。");
          Navigator.push(
              context,
              MaterialPageRoute(
                settings: const RouteSettings(name: "/new"),
                builder: (BuildContext context) => InputForm(null)
              ),
          );
        }
      ),
    );
  }

  // リスクの項目を構成する関数
  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    // 変数を初期化する
    String borrowOrLend;
    String limitDate = document['data'].toDate().toString().substring(0, 10);

    if (document['borrowOrLend'] == "lend") {
      borrowOrLend = "貸";
    } else {
      borrowOrLend = "借";
    }
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.android),
            title: Text("【$borrowOrLend】: ${document['stuff']}"),
            subtitle: Text("期限：$limitDate¥n 相手：${document['user']}"),
          ),
          ButtonBarTheme(
            data: ButtonBarThemeData(buttonTextTheme: ButtonTextTheme.accent),
            child: ButtonBar(
              children: <Widget>[
                TextButton(
                    onPressed: () {
                      print("編集ボタンを押しました。");
                      // 画面遷移する。
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              settings: const RouteSettings(name: "/edit"),
                              builder: (BuildContext context) => InputForm(document)
                          ),
                      );
                    },
                    child: const Text("編集")
                ),
              ],
            )
          ),
        ]
      ),
    );
  }

  /**
   * ダイアログを表示させる関数
   */
  void showBasicDialog(BuildContext context) {
    // 変数を初期化する。
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String email = "";
    String password = "";

    if (userAuth.currentUser!.isAnonymous) {
      showDialog(
          context: context,
          builder: (BuildContext context) =>
            AlertDialog(
              title: Text("ログイン/登録ダイアログ"),
              content: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        icon: const Icon(Icons.mail),
                        labelText: 'Email',
                      ),
                      onSaved: (String? value) {
                        email = value!;
                      },
                      validator: (value) {
                        if(value!.isEmpty) {
                          return 'Emailは入力必須です。';
                        } else {
                          return null;
                        }
                      },
                    ),
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.vpn_key),
                        labelText: 'Password',
                      ),
                      onSaved: (String? value) {
                        password = value!;
                      },
                      validator: (value) {
                        if(value!.isEmpty) {
                          return 'Passwordは入力必須です。';
                        } else if (value!.length < 6) {
                          return 'Passwordは6桁以上です。';
                        } else {
                          return null;
                        }
                      },
                    ),
                  ],
                ),
              ),
              // ボタンの配置
              actions: <Widget> [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('キャンセル')
                ),
                TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // ユーザーを登録する。
                        _createUser(context, email, password);
                      }
                      Navigator.pushNamedAndRemoveUntil(context, "/list", (_) => false);
                    },
                    child: Text('登録')
                ),
                TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // ユーザーを登録する。
                        _signIn(context, email, password);
                      }
                      Navigator.pushNamedAndRemoveUntil(context, "/list", (_) => false);
                    },
                    child: Text('ログイン')
                ),
              ],
            ),
      );
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) =>
              AlertDialog(
                title: Text("確認ダイアログ"),
                content: Text(userAuth.currentUser!.email! + "でログインしています。"),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('キャンセル')
                  ),
                  TextButton(
                      onPressed: () async {
                        await _signOut();
                        Navigator.pushNamedAndRemoveUntil(context, "/list", (_) => false);
                      },
                      child: Text('ログアウト')
                  ),
                ],
              ),
      );
    }
  }

  /**
   * サインアウト用の関数
   */
  Future<void> _signOut() async {
    try {
      await userAuth.signOut();
      await userAuth.signInAnonymously();
    } catch(e) {
      print(e);
      Fluttertoast.showToast(msg: "Firebaseのログインに失敗しました。");
    }
  }

  /**
   * サインイン処理用の関数
   */
  Future<void> _signIn(BuildContext context, String email, String password) async {
    try {
      await userAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch(e) {
      print(e);
      Fluttertoast.showToast(msg: "Firebaseのログインに失敗しました。");
    }
  }

  /**
   * ユーザーを新規登録するための関数
   */
  Future<void> _createUser(BuildContext context, String email, String password) async {
    await userAuth.createUserWithEmailAndPassword(email: email, password: password);
  }
}