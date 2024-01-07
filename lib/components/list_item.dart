import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/components/vars.dart';
import 'package:lapor_book/models/akun.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/models/laporan.dart';
import 'package:lapor_book/models/like.dart';

class ListItem extends StatefulWidget {
  final Akun akun;
  final Laporan laporan;
  final bool isLaporanku;
  const ListItem({
    super.key,
    required this.laporan,
    required this.akun,
    required this.isLaporanku,
  });

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  List<Like> listLike = [];
  Like privateLike = Like(
    docId: '',
    targetId: '',
    date: DateTime.now(),
    uid: '',
  );

  void deleteLaporan() async {
    try {
      CollectionReference laporanCollection = _db.collection('laporan');

      if (widget.laporan.gambar != '') {
        await _storage.refFromURL(widget.laporan.gambar!).delete();
      }

      await laporanCollection.doc(widget.laporan.docId).delete();
    } catch (e) {
      print(e);
    }
  }

  void getLike() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
          .collection('like')
          .where('targetId', isEqualTo: widget.laporan.docId)
          .get();

      setState(() {
        listLike.clear();
        for (var documents in querySnapshot.docs) {
          listLike.add(
            Like(
                docId: documents.data()['docId'],
                uid: documents.data()['uid'],
                targetId: documents.data()['targetId'],
                date: documents.data()['date'].toDate()),
          );
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void getPrivateLike() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
          .collection('like')
          .where('uid', isEqualTo: widget.akun.uid)
          .where('targetId', isEqualTo: widget.laporan.docId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var likeData = querySnapshot.docs.first.data();
        setState(() {
          privateLike = Like(
            docId: likeData['docId'],
            uid: likeData['uid'],
            targetId: likeData['targetId'],
            date: likeData['date'].toDate(),
          );
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    getLike();
    getPrivateLike();
    return Container(
      decoration: BoxDecoration(
          border: Border.all(width: 2),
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(10))),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detail',
            arguments: {
              'akun': widget.akun,
              "laporan": widget.laporan,
              'like': listLike,
              'privateLike': privateLike,
            },
          );
        },
        onLongPress: () {
          if (widget.isLaporanku) {
            showDialog(
              context: context,
              builder: (BuildContext buildContext) {
                return AlertDialog(
                  title: Text('Hapus ${widget.laporan.judul}?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(buildContext);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        deleteLaporan();
                      },
                      child: const Text('Delete'),
                    )
                  ],
                );
              },
            );
          }
        },
        child: Column(
          children: [
            widget.laporan.gambar != ''
                ? Image.network(
                    widget.laporan.gambar!,
                    width: 130,
                    height: 130,
                  )
                : Image.asset(
                    'assets/istock-default.jpg',
                    width: 130,
                    height: 130,
                  ),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(width: 2),
                ),
              ),
              child: Text(
                widget.laporan.judul,
                style: headerStyle(
                  level: 4,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.laporan.status == "Posted"
                          ? warnaStatus[0]
                          : widget.laporan.status == "Process"
                              ? warnaStatus[1]
                              : warnaStatus[2],
                      border: const Border(
                        right: BorderSide(width: 2),
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      widget.laporan.status,
                      style: headerStyle(level: 5, dark: false),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                        color: successColor,
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(8))),
                    child: Text(
                      // DateFormat('dd/MM/yyyy').format(widget.laporan.tanggal)
                      listLike.length.toString(),
                      style: headerStyle(level: 5, dark: false),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
