/**
 * 入力画面用のファイル
 */

import 'package:flutter/material.dart';
import 'promise_model.dart';

/**
 * InputFormクラス
 */
class InputForm extends StatefulWidget {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('貸し借り入力'),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                print("保存ボタンが押されました。");
              },
              icon: Icon(Icons.save)
          ),
          IconButton(
              onPressed: () {
                print("削除ボタンが押されました。");
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
                  hintText: (_promise.borrowOrLend == "lend" ? "貸した人" : "借りた人" ),
                  labelText: 'Name',
                ),
                onSaved: (String? value) {
                  _promise.user = value!;
                },
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