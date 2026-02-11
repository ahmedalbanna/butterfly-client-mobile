import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'http_client.dart';

final logger = Logger();

/// Upload response model
class UploadResult {
  final String url;
  final String filename;
  final int size;
  final String type;

  UploadResult({
    required this.url,
    required this.filename,
    required this.size,
    required this.type,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      url: json['url'] as String,
      filename: json['filename'] as String,
      size: json['size'] as int,
      type: json['type'] as String,
    );
  }
}

/// Custom exception for upload-related errors
class UploadException implements Exception {
  final String message;

  UploadException(this.message);

  @override
  String toString() => message;
}

/// Upload service for file uploads
class UploadService {
  final HttpClient _httpClient;

  UploadService(this._httpClient);

  /// Upload image file
  Future<UploadResult> uploadImage(File file) async {
    try {
      logger.d('[UploadService] Uploading image: ${file.path}');

      // Determine content type from file extension
      final extension = file.path.split('.').last.toLowerCase();
      String contentType;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        case 'webp':
          contentType = 'image/webp';
          break;
        default:
          contentType = 'image/jpeg';
      }

      // Create multipart form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: MediaType.parse(contentType),
        ),
      });

      final response = await _httpClient.post(
        '/admin/upload',
        data: formData,
      );

      if (response.data['success'] == true) {
        return UploadResult.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw UploadException(
          response.data['error'] ?? 'Failed to upload image',
        );
      }
    } catch (e) {
      logger.e('[UploadService] Error uploading image: $e');
      if (e is UploadException) rethrow;
      throw UploadException('Failed to upload image: ${e.toString()}');
    }
  }
}

/// Provider for UploadService
final uploadServiceProvider = Provider<UploadService>((ref) {
  final httpClient = HttpClient();
  return UploadService(httpClient);
});
