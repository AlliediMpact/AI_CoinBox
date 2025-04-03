import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Add missing import for File
import '../../services/kyc_service.dart';

class KYCSubmissionScreen extends StatefulWidget {
  final String userId;

  const KYCSubmissionScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<KYCSubmissionScreen> createState() => _KYCSubmissionScreenState();
}

class _KYCSubmissionScreenState extends State<KYCSubmissionScreen> {
  XFile? _idDocument;
  XFile? _proofOfAddress;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickDocument(bool isIdDocument) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isIdDocument) {
          _idDocument = pickedFile;
        } else {
          _proofOfAddress = pickedFile;
        }
      });
    }
  }

  Future<void> _submitKYC() async {
    if (_idDocument == null || _proofOfAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required documents.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await KYCService.submitKYC(
        userId: widget.userId,
        idDocumentPath: _idDocument!.path,
        proofOfAddressPath: _proofOfAddress!.path,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KYC submitted successfully.')),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting KYC: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Submission'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload your KYC documents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _pickDocument(true),
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _idDocument == null
                    ? const Center(child: Text('Tap to upload ID Document'))
                    : Image.file(
                        File(_idDocument!.path),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _pickDocument(false),
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _proofOfAddress == null
                    ? const Center(child: Text('Tap to upload Proof of Address'))
                    : Image.file(
                        File(_proofOfAddress!.path),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitKYC,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit KYC'),
            ),
          ],
        ),
      ),
    );
  }
}
