import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/models/laporan.dart';

class StatusDialog extends StatefulWidget {
  final Laporan laporan;
  const StatusDialog({super.key, required this.laporan});

  @override
  State<StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<StatusDialog> {
  late String status;

  final _db = FirebaseFirestore.instance;

  void updateStatus() async {
    try {
      CollectionReference laporanCollection = _db.collection('laporan');

      await laporanCollection
          .doc(widget.laporan.docId)
          .update({'status': status});
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      status = widget.laporan.status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: primaryColor,
      content: Container(
        height: 350,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(widget.laporan.judul),
            const SizedBox(
              height: 15,
            ),
            RadioListTile(
              title: const Text('Posted'),
              value: 'Posted',
              groupValue: status,
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),
            const SizedBox(height: 15),
            RadioListTile(
              title: const Text('Process'),
              value: 'Process',
              groupValue: status,
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),
            const SizedBox(height: 15),
            RadioListTile(
              title: const Text('Done'),
              value: 'Done',
              groupValue: status,
              onChanged: (value) {
                setState(() {
                  status = value!;
                });
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                updateStatus();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ubah Status'),
            ),
          ],
        ),
      ),
    );
  }
}
