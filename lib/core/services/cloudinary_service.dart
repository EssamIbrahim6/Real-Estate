import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';

abstract class CloudinaryService {
  Future<String> uploadImage(File file);
}

class CloudinaryServiceImpl implements CloudinaryService {
  final String cloudName;
  final String uploadPreset;
  // xo5cninj
  const CloudinaryServiceImpl({
    this.cloudName = 'xo5cninj', // Replace with your Cloudinary Cloud Name
    this.uploadPreset =
        'real_estate_preset', // Replace with your unsigned preset
  });

  @override
  Future<String> uploadImage(File file) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(responseBody) as Map<String, dynamic>;
        return data['secure_url'] as String;
      } else {
        // Fallback: If no preset configured, return local path indicator or throw user-friendly error
        throw ServerException(
          message:
              'Failed to upload image to Cloudinary: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Image upload error: $e');
    }
  }
}
