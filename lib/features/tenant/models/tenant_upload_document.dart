import 'package:dio/dio.dart';

class UploadSellerDocumentRequest {
  final String type;
  final String filePath;
  final String? fileName;

  const UploadSellerDocumentRequest({
    required this.type,
    required this.filePath,
    this.fileName,
  });

  Future<FormData> toFormData() async {
    final pathParts = filePath.split('/');
    final resolvedFileName =
        fileName ??
        (pathParts.isNotEmpty && pathParts.last.trim().isNotEmpty
            ? pathParts.last
            : 'document');

    return FormData.fromMap({
      'type': type,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: resolvedFileName,
      ),
    });
  }
}
