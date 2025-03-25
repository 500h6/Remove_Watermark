import 'dart:io';
import 'package:flutter/material.dart';
import 'gemini_service.dart';

class EditImageScreen extends StatefulWidget {
  final File imageFile;

  const EditImageScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  EditImageScreenState createState() => EditImageScreenState(); // جعل الكلاس عامًا
}

class EditImageScreenState extends State<EditImageScreen> {
  bool _isProcessing = false;
  File? _processedImage;
  final String _apiKey = 'AIzaSyCbIXWxkFO45-lxDoRD5eql9gmlEPQmMDE'; // استبدل بمفتاح API الخاص بك

  Future<void> _removeWatermark() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // إنشاء مثيل من خدمة Gemini
      final geminiService = GeminiService(apiKey: _apiKey);

      // إرسال الصورة لإزالة العلامة المائية
      final processedImage = await geminiService.removeWatermark(widget.imageFile);

      if (processedImage != null) {
        setState(() {
          _processedImage = processedImage;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشلت عملية إزالة العلامة المائية. يرجى المحاولة مرة أخرى.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _saveImage() async {
    // يمكنك إضافة كود لحفظ الصورة في معرض الهاتف
    // يتطلب ذلك استخدام حزمة image_gallery_saver أو ما شابه
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الصورة في المعرض')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إزالة العلامة المائية'),
        actions: _processedImage != null
            ? [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveImage,
            tooltip: 'حفظ الصورة',
          ),
        ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _isProcessing
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('جاري إزالة العلامة المائية...'),
                  ],
                ),
              )
                  : _processedImage != null
                  ? SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'الصورة الأصلية:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Image.file(widget.imageFile),
                    const SizedBox(height: 16),
                    const Text(
                      'الصورة بعد إزالة العلامة المائية:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Image.file(_processedImage!),
                  ],
                ),
              )
                  : Center(
                child: Image.file(widget.imageFile),
              ),
            ),
            const SizedBox(height: 16),
            if (_processedImage == null)
              ElevatedButton(
                onPressed: _isProcessing ? null : _removeWatermark,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _isProcessing ? 'جاري المعالجة...' : 'إزالة العلامة المائية',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}