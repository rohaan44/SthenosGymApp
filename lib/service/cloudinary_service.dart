import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
// import 'dart:io';

class CloudinaryService {
  final cloudinary = CloudinaryPublic(
    'digpljra8', // Dashboard se
    'sthenos', // Unsigned preset name
    cache: false,
  );

  Future<String?> uploadImage(XFile imageFile) async {
    try {
      CloudinaryFile cloudinaryFile;
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        cloudinaryFile = CloudinaryFile.fromBytesData(
          bytes,
          identifier: imageFile.name,
          resourceType: CloudinaryResourceType.Image,
        );
      } else {
        cloudinaryFile = CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        );
      }

      final response = await cloudinary.uploadFile(cloudinaryFile);
      log("Response: *********** ${response.secureUrl}");
      return response.secureUrl; // yeh URL database mein store karo
    } catch (e) {
      log('Upload error:*********** $e');
      try {
        final dynamic dioError = e;
        if (dioError.response != null) {
          log('CLOUDINARY EXACT ERROR: ${dioError.response?.data}');
        }
      } catch (_) {}
      return null;
    }
  }
}
