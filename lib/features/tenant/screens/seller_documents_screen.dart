import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tenant_upload_document.dart';
import '../state/seller_onboarding_provider.dart';

class SellerDocumentsScreen extends StatefulWidget {
  const SellerDocumentsScreen({super.key});

  @override
  State<SellerDocumentsScreen> createState() => _SellerDocumentsScreenState();
}

class _SellerDocumentsScreenState extends State<SellerDocumentsScreen> {
  final Map<String, String?> _selectedNames = {};
  final Map<String, String?> _selectedPaths = {};
  String? _uploadingType;

  Future<void> _pickFile(String type) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    if (file.path == null || file.path!.trim().isEmpty) return;

    setState(() {
      _selectedNames[type] = file.name;
      _selectedPaths[type] = file.path;
    });
  }

  Future<void> _upload(
    BuildContext context, {
    required String documentType,
    required String label,
  }) async {
    final fileName = _selectedNames[documentType];
    final filePath = _selectedPaths[documentType];

    if (filePath == null || filePath.trim().isEmpty || fileName == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Choose a file for $label first')));
      return;
    }

    setState(() {
      _uploadingType = documentType;
    });

    final provider = context.read<SellerOnboardingProvider>();

    final ok = await provider.uploadDocument(
      UploadSellerDocumentRequest(
        documentType: documentType,
        filePath: filePath,
        fileName: fileName,
      ),
    );

    if (!mounted) return;

    setState(() {
      _uploadingType = null;
    });

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$label uploaded')));
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'uploaded':
      case 'approved':
        return Colors.green;
      case 'under_review':
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _statusLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((e) => e.trim().isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerOnboardingProvider>(
      builder: (context, provider, _) {
        final docs = provider.status?.documents?.requiredDocuments ?? const [];

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8FAFC),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('Verification documents'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (provider.error != null && provider.error!.trim().isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      border: Border.all(color: Colors.red.withOpacity(0.20)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (docs.isEmpty)
                  const _DocumentsEmptyState()
                else
                  ...docs.map(
                    (doc) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DocumentCard(
                        title: doc.label,
                        subtitle: _subtitleForType(doc.type),
                        statusText: _statusLabel(doc.status),
                        statusColor: _statusColor(doc.status),
                        currentFileName: doc.fileName,
                        selectedFileName: _selectedNames[doc.type],
                        loading:
                            provider.isLoading && _uploadingType == doc.type,
                        onPick: () => _pickFile(doc.type),
                        onUpload: () => _upload(
                          context,
                          documentType: doc.type,
                          label: doc.label,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _subtitleForType(String type) {
    switch (type) {
      case 'business_registration':
        return 'Upload your registration or incorporation document.';
      case 'proof_of_address':
        return 'Upload a recent document showing your address.';
      case 'owner_id':
        return 'Upload a valid identification document.';
      default:
        return 'Upload the required file.';
    }
  }
}

class _DocumentsEmptyState extends StatelessWidget {
  const _DocumentsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Text(
        'No document requirements were returned yet.',
        style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusText;
  final Color statusColor;
  final String? currentFileName;
  final String? selectedFileName;
  final bool loading;
  final VoidCallback onPick;
  final VoidCallback onUpload;

  const _DocumentCard({
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.statusColor,
    required this.currentFileName,
    required this.selectedFileName,
    required this.loading,
    required this.onPick,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final displayFileName = selectedFileName ?? currentFileName;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withOpacity(0.25)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF6B7280), height: 1.4),
          ),
          const SizedBox(height: 12),
          if (displayFileName != null && displayFileName.trim().isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                displayFileName,
                style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
              ),
            ),
          if (displayFileName != null && displayFileName.trim().isNotEmpty)
            const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: loading ? null : onPick,
                  child: const Text('Choose file'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: loading ? null : onUpload,
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Upload'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
