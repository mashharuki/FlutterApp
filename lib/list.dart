/**
 * リスト一覧用のDartファイル
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('promise').snapshots(),
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
        ]
      ),
    );
  }
}