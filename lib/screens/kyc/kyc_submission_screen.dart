import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/kyc_service.dart';

class KYCSubmissionScreen extends StatefulWidget {
  final String userId;

  const KYCSubmissionScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<KYCSubmissionScreen> createState() => _KYCSubmissionScreenState();
}

class _KYCSubmissionScreenState extends State<KYCSubmissionScreen> {
  File? _idDocument;
  File? _proofOfAddress;
  bool _isSubmitting = false;

  Future<void> _pickFile(bool isIdDocument) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isIdDocument) {
          _idDocument = File(pickedFile.path);
        } else {
          _proofOfAddress = File(pickedFile.path);
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
              'Upload your KYC documents to verify your account.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildFilePicker(
              label: 'ID Document',
              file: _idDocument,
              onPick: () => _pickFile(true),
            ),
            const SizedBox(height: 16),
            _buildFilePicker(
              label: 'Proof of Address',
              file: _proofOfAddress,
              onPick: () => _pickFile(false),
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

  Widget _buildFilePicker({
    required String label,
    required File? file,
    required VoidCallback onPick,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(file == null ? 'No file selected' : file.path.split('/').last),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onPick,
          child: Text('Upload $label'),
        ),
      ],
    );
  }
}
