import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class GeminiService {
  final String apiKey;

  GeminiService({required this.apiKey});

  Future<File?> removeWatermark(File imageFile) async {
    try {
      // Convert the image to bytes
      final bytes = await imageFile.readAsBytes();

      // Setup Gemini API
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      // Prepare the request
      // Convert the image to appropriate format for the API
      final imagePart = DataPart(
        'image/jpeg',
        bytes,
      );

      // Prepare the content for the request
      final prompt = TextPart('Please remove the watermark from this image without affecting other parts of the image.');
      
      // Create a list of parts
      final parts = [prompt, imagePart];

      // Create the Content object with positional arguments
      final content = Content('user', parts);

      // Send the request
      final response = await model.generateContent([content]);

      // Extract the image or URL from the response
      final processedImageData = await extractImageFromResponse(response);

      if (processedImageData != null) {
        // Save the processed image to a temporary directory
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/processed_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(processedImageData);

        return tempFile;
      }
    } catch (e) {
      debugPrint('Error while removing watermark: $e');
      return null;
    }

    return null;
  }

  // Asynchronous method to extract the image or URL from the response
  Future<Uint8List?> extractImageFromResponse(GenerateContentResponse response) async {
    try {
      if (response.text != null) {
        // If the response contains a URL for the image
        final urlRegExp = RegExp(r'https?:\/\/[^\s]+\.(jpg|jpeg|png)');
        final match = urlRegExp.firstMatch(response.text!);
        if (match != null) {
          // Download the image from the URL
          final imageUrl = match.group(0)!;
          final imageResponse = await http.get(Uri.parse(imageUrl));
          return imageResponse.bodyBytes;
        }

        // If the response contains base64-encoded image data
        final base64RegExp = RegExp(r'data:image\/(jpeg|png|jpg);base64,(.+?)');
        final base64Match = base64RegExp.firstMatch(response.text!);
        if (base64Match != null) {
          final base64Data = base64Match.group(2)!;
          return base64Decode(base64Data);
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error while extracting image: $e');
      return null;
    }
  }
}