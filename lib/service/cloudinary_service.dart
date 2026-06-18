import 'dart:developer';
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
      final bytes = await imageFile.readAsBytes();
      
      // Ensure the identifier has an extension, otherwise Dio might send it as application/octet-stream
      // which Cloudinary rejects with 'Missing required parameter - file'.
      String fileName = imageFile.name;
      if (fileName.isEmpty) {
        fileName = 'upload.jpg';
      } else if (!fileName.contains('.')) {
        fileName = '$fileName.jpg';
      }

      final cloudinaryFile = CloudinaryFile.fromBytesData(
        bytes,
        identifier: fileName,
        resourceType: CloudinaryResourceType.Image,
      );

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
