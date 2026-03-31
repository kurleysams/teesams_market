class UploadSellerDocumentRequest {
  final String documentType;
  final String filePath;
  final String fileName;

  UploadSellerDocumentRequest({
    required this.documentType,
    required this.filePath,
    required this.fileName,
  });
}
