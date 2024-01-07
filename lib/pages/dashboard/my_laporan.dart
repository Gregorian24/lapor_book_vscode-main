import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/components/list_item.dart';
import 'package:lapor_book/models/akun.dart';
import 'package:lapor_book/models/laporan.dart';

class MyLaporan extends StatefulWidget {
  final Akun akun;
  const MyLaporan({super.key, required this.akun});

  @override
  State<MyLaporan> createState() => _MyLaporanState();
}

class _MyLaporanState extends State<MyLaporan> {
  final _db = FirebaseFirestore.instance;

  List<Laporan> listLaporan = [];

  void getLaporan() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db
          .collection('laporan')
          .where('uid', isEqualTo: widget.akun.uid)
          .get();

      setState(() {
        listLaporan.clear();
        for (var documents in querySnapshot.docs) {
          listLaporan.add(
            Laporan(
              uid: documents.data()['uid'],
              docId: documents.data()['docId'],
              judul: documents.data()['judul'],
              instansi: documents.data()['instansi'],
              nama: documents.data()['nama'],
              status: documents.data()['status'],
              tanggal: documents.data()['tanggal'].toDate(),
              maps: documents.data()['maps'],
              deskripsi: documents.data()['deskripsi'],
              gambar: documents.data()['gambar'],
            ),
          );
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    getLaporan();
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1 / 1.233),
          itemCount: listLaporan.length,
          itemBuilder: (context, index) {
            return ListItem(
              akun: widget.akun,
              laporan: listLaporan[index],
              isLaporanku: true,
            );
          },
        ),
      ),
    );
  }
}
