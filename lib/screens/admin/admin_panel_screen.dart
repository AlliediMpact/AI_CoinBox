import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/error_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  String _searchQuery = '';

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final query = FirebaseFirestore.instance.collection('users');
    final userDocs = _searchQuery.isEmpty
        ? await query.get()
        : await query
            .where('fullName', isGreaterThanOrEqualTo: _searchQuery)
            .where('fullName', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
            .get();

    return userDocs.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> _updateUserRole(String userId, String role) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'role': role,
    });
  }

  Future<void> _suspendUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isSuspended': true,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User suspended')),
      );
    } catch (error, stackTrace) {
      await ErrorService.logError(error.toString(), stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error suspending user: ${error.toString()}')),
      );
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted')),
      );
    } catch (error, stackTrace) {
      await ErrorService.logError(error.toString(), stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Name or Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final users = snapshot.data ?? [];

                if (users.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(user['fullName'] ?? 'Unknown User'),
                        subtitle: Text('Email: ${user['email']}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'Suspend') {
                              await _suspendUser(user['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User suspended')),
                              );
                            } else if (value == 'Delete') {
                              await _deleteUser(user['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User deleted')),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'Suspend',
                              child: Text('Suspend User'),
                            ),
                            const PopupMenuItem(
                              value: 'Delete',
                              child: Text('Delete User'),
                            ),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('User Details'),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Name: ${user['fullName']}'),
                                  Text('Email: ${user['email']}'),
                                  Text('Role: ${user['role']}'),
                                  Text('Status: ${user['isSuspended'] == true ? 'Suspended' : 'Active'}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
