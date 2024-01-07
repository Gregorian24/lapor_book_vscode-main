import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapor_book/components/status_dialog.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/components/vars.dart';
import 'package:lapor_book/models/akun.dart';
import 'package:lapor_book/models/laporan.dart';
import 'package:lapor_book/models/like.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool likedNow = false;
  Future launch(String url) async {
    if (url == '') return;
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Cannot call $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Akun akun = arguments['akun'];
    final Laporan laporan = arguments['laporan'];
    final List<Like> listlike = arguments['like'];
    Like privateLike = arguments['privateLike'];

    Future<void> liked() async {
      try {
        CollectionReference likeCollection = _firestore.collection('like');

        // Convert DateTime to Firestore Timestamp
        Timestamp timestamp = Timestamp.fromDate(DateTime.now());

        final id = likeCollection.doc().id;

        await likeCollection.doc(id).set({
          'uid': _auth.currentUser!.uid,
          'docId': id,
          'targetId': laporan.docId,
          'date': timestamp,
        }).catchError((e) {
          throw e;
        });

        privateLike = Like(
          uid: _auth.currentUser!.uid,
          docId: id,
          targetId: laporan.docId,
          date: timestamp.toDate(),
        );

        setState(() {
          likedNow = true;
        });
      } catch (e) {
        final snackbar = SnackBar(content: Text(e.toString()));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Detail Laporan',
          style: headerStyle(level: 3, dark: false),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(
                laporan.judul,
                style: headerStyle(level: 2),
              ),
              const SizedBox(
                height: 15,
              ),
              laporan.gambar != ''
                  ? Image.network(
                      laporan.gambar!,
                    )
                  : Image.asset(
                      'assets/istock-default.jpg',
                    ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textStatus(
                      laporan.status,
                      laporan.status == "Posted"
                          ? warnaStatus[0]
                          : laporan.status == "Process"
                              ? warnaStatus[1]
                              : warnaStatus[2],
                      Colors.white),
                  textStatus(laporan.instansi, Colors.white, Colors.black),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  if (privateLike.uid != akun.uid && likedNow == false)
                    IconButton(
                      onPressed: () {
                        liked();
                      },
                      icon: Icon(Icons.thumb_up),
                    ),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text('Disukai ${listlike.length} orang'),
                  ),
                ],
              ),
              ListTile(
                title: const Text('Nama Pelapor'),
                subtitle: Text(laporan.nama),
                leading: const Icon(Icons.person),
              ),
              ListTile(
                title: const Text('Tanggal'),
                subtitle: Text(
                  DateFormat('dd MMMM yyyy').format(laporan.tanggal),
                ),
                trailing: IconButton(
                  onPressed: () {
                    launch(laporan.maps);
                  },
                  icon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Text(
                'Deskripsi',
                style: headerStyle(level: 2),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(laporan.deskripsi ?? 'No description'),
              const SizedBox(
                height: 50,
              ),
              if (akun.role == 'admin')
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatusDialog(
                              laporan: laporan,
                            );
                          });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Ubah Status'),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Komentar',
                  style: headerStyle(level: 3),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }

  Container textStatus(String text, var bgColor, var fgColor) {
    return Container(
      alignment: Alignment.center,
      width: 150,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: TextStyle(color: fgColor),
      ),
    );
  }
}
