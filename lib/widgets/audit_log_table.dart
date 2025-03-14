import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('audit_logs').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        return DataTable(
          columns: [
            DataColumn(label: Text('Admin ID')),
            DataColumn(label: Text('Action')),
            DataColumn(label: Text('Timestamp')),
          ],
          rows: snapshot.data!.docs.map((doc) {
            return DataRow(cells: [
              DataCell(Text(doc['adminId'])),
              DataCell(Text(doc['action'])),
              DataCell(Text(doc['timestamp'].toDate().toString())),
            ]);
          }).toList(),
        );
      },
    );
  }
}
