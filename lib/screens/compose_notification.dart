import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComposeNotification extends StatelessWidget {
  final TextEditingController _messageController = TextEditingController();

  void _sendNotification() {
    FirebaseFirestore.instance.collection('notifications').add({
      'message': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Compose Notification')),
      body: Column(
        children: [
          TextField(controller: _messageController),
          ElevatedButton(
            onPressed: _sendNotification,
            child: Text('Send'),
          ),
        ],
      ),
    );
  }
}
