/**
 * 入力画面用のファイル
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'promise_model.dart';
import 'user_auth.dart';

/**
 * InputFormクラス
 */
class InputForm extends StatefulWidget {
  // 引数
  final DocumentSnapshot? document;
  InputForm(this.document);

  @override
  _MyInputFormState createState() => _MyInputFormState();
}

/**
 * _MyInputFormStateクラス
 */
class _MyInputFormState extends State<InputForm> {
  // 変数を初期化する。
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PromiseModel _promise = PromiseModel("borrow", "", "", DateTime.now());

  /**
   * _setLendOrRent関数
   */
  void _setLendOrRent(String value) {
    setState(() {
      _promise.borrowOrLend = value;
    });
  }

  /**
   * 時間を設定する関数
   */
  Future <DateTime?> _selectTime(BuildContext context) {
    // DatePickerを表示する。
    return showDatePicker(
        context: context,
        initialDate: _promise.date,
        firstDate: DateTime(_promise.date.year - 2),
        lastDate: DateTime(_promise.date.year + 2)
    );
  }

  // 入力画面の構成
  Widget build(BuildContext context) {
    // promiseテーブルからデータを取得する。
    DocumentReference _mainReference = FirebaseFirestore.instance
        .collection('users').doc(userAuth.currentUser!.uid)
        .collection('promises').doc();
    // 削除用のフラグ
    bool isDeletedDocument = false;
    // 編集データの作成
    if (widget.document != null) {
      // 日付・貸し借り情報更新時に、再buildされるため、値が更新されるのを防ぐ。
      if (_promise.user == "" && _promise.stuff == "") {
        _promise.borrowOrLend = widget.document!['borrowOrLend'];
        _promise.user = widget.document!['user'];
        _promise.stuff = widget.document!['stuff'];
        _promise.date = widget.document!['date'].toDate();
      }
      // IDに合致するデータを取得する。
      _mainReference = FirebaseFirestore.instance
          .collection('users').doc(userAuth.currentUser!.uid)
          .collection('promises').doc(widget.document!.id);
      isDeletedDocument = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('貸し借り入力'),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                print("保存ボタンが押されました。");
                // 入力チェックを行う。
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // データをFireBaseに登録する。
                  _mainReference.set({
                    'borrowOrLend': _promise.borrowOrLend,
                    'user': _promise.user,
                    'stuff': _promise.stuff,
                    'date': _promise.date
                  });
                  // 前のページに遷移する。
                  Navigator.pop(context);
                }
              },
              icon: Icon(Icons.save)
          ),
          IconButton(
              onPressed: () {
                if (isDeletedDocument) {
                  print("削除ボタンが押されました。");
                  _mainReference.delete();
                  Navigator.pop(context);
                } else {
                  return null;
                }
              },
              icon: Icon(Icons.delete)
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: <Widget>[
              RadioListTile(
                  value: "borrow",
                  groupValue: _promise.borrowOrLend,
                  title: Text("借りた"),
                  onChanged: (String? value) {
                    print("借りたをタッチしました。");
                    _setLendOrRent(value!);
                  },
              ),
              RadioListTile(
                value: "lend",
                groupValue: _promise.borrowOrLend,
                title: Text("貸した"),
                onChanged: (String? value) {
                  print("貸したをタッチしました。");
                  _setLendOrRent(value!);
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  icon: const Icon(Icons.person),
                  hintText: '相手の名前',
                  labelText: 'Name',
                ),
                onSaved: (String? value) {
                  _promise.user = value!;
                },
                validator: (value) {
                  if(value!.isEmpty) {
                    return '名前は入力必須です。';
                  } else {
                    return null;
                  }
                },
                // 初期値を設定する。
                initialValue: _promise.user,
              ),
              TextFormField(
                decoration: InputDecoration(
                  icon: const Icon(Icons.business_center),
                  hintText: '貸したもの、借りたもの',
                  labelText: 'Loan',
                ),
                onSaved: (String? value) {
                  _promise.stuff = value!;
                },
                validator: (value) {
                  if(value!.isEmpty) {
                    return '貸したもの、借りたものは入力必須です。';
                  } else {
                    return null;
                  }
                },
                // 初期値を設定する。
                initialValue: _promise.stuff,
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("締切日：${_promise.date.toString().substring(0, 10)}"),
              ),
              ElevatedButton(
                  onPressed: () {
                    print("締切日変更ボタンが押されました。");
                    _selectTime(context).then((time){
                      if (time != null && time != _promise.date) {
                        setState(() {
                          _promise.date = time;
                        });
                      }
                    });
                  },
                  child: const Text("締切日変更"),
              )
            ],
          ),
        ),
      ),
    );
  }
}