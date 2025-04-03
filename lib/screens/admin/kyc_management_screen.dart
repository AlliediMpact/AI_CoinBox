import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/kyc_service.dart';
import '../../services/error_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KYCManagementScreen extends StatefulWidget {
  const KYCManagementScreen({Key? key}) : super(key: key);

  @override
  State<KYCManagementScreen> createState() => _KYCManagementScreenState();
}

class _KYCManagementScreenState extends State<KYCManagementScreen> {
  String _searchQuery = '';

  Future<List<Map<String, dynamic>>> _fetchPendingKYCs() async {
    final query = FirebaseFirestore.instance
        .collection('kyc')
        .where('status', isEqualTo: KYCStatus.pending.toString());

    final kycDocs = _searchQuery.isEmpty
        ? await query.get()
        : await query.where('userId', isEqualTo: _searchQuery).get();

    return kycDocs.docs.map((doc) => doc.data()).toList();
  }

  Future<void> _approveKYC(String userId) async {
    try {
      await KYCService.approveKYC(userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KYC Approved')),
      );
    } catch (error, stackTrace) {
      await ErrorService.logError(error.toString(), stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving KYC: ${error.toString()}')),
      );
    }
  }

  Future<void> _rejectKYC(String userId, String reason) async {
    try {
      await KYCService.rejectKYC(userId, reason);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KYC Rejected')),
      );
    } catch (error, stackTrace) {
      await ErrorService.logError(error.toString(), stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting KYC: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<bool>(
      future: AuthService.isAdmin(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !(snapshot.data ?? false)) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Access Denied',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('KYC Management'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search by User ID',
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
                  future: _fetchPendingKYCs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final pendingKYCs = snapshot.data ?? [];

                    if (pendingKYCs.isEmpty) {
                      return const Center(child: Text('No pending KYC submissions.'));
                    }

                    return ListView.builder(
                      itemCount: pendingKYCs.length,
                      itemBuilder: (context, index) {
                        final kyc = pendingKYCs[index];

                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text('User ID: ${kyc['userId']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Submitted At: ${kyc['submittedAt']}'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        await _approveKYC(kyc['userId']);
                                      },
                                      child: const Text('Approve'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await _rejectKYC(
                                          kyc['userId'],
                                          'Invalid documents',
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('KYC Details'),
                                  content: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('User ID: ${kyc['userId']}'),
                                      Text('ID Document: ${kyc['idDocumentUrl']}'),
                                      Text('Proof of Address: ${kyc['proofOfAddressUrl']}'),
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
      },
    );
  }
}
