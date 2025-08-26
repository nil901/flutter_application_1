import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class UploadIntroductionWidget extends StatefulWidget {
  @override
  _UploadIntroductionWidgetState createState() =>
      _UploadIntroductionWidgetState();
}

class _UploadIntroductionWidgetState extends State<UploadIntroductionWidget> {
  FilePickerResult? selectedFile;
  bool isLoading = false;

  final Map<String, MediaType> mimeTypes = {
    'png': MediaType('image', 'png'),
    'jpg': MediaType('image', 'jpeg'),
    'jpeg': MediaType('image', 'jpeg'),
    'pdf': MediaType('application', 'pdf'),
    'xls': MediaType('application', 'vnd.ms-excel'),
    'xlsx': MediaType(
        'application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
    'mp4': MediaType('video', 'mp4'),
  };
Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    if (Platform.version.contains("13")) {
      // Android 13 (API 33+)
      var image = await Permission.photos.request();
      return image.isGranted;
    } else {
      var status = await Permission.storage.request();
      return status.isGranted;
    }
  }
  return true; // iOS or web
}
Future<File?> compressImage(File file) async {
  // bool granted = await requestStoragePermission();
  // if (!granted) {
  //   print('Permission not granted');
  //   return null;
  // }

  final dir = await getTemporaryDirectory();
  final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 30,
  );

  if (result == null) return null;
  return File(result.path);
}


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Upload an introduction",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Upload box
          Container(
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[100],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.document_scanner,
                      size: 40, color: Colors.grey[700]),
                  const SizedBox(height: 10),
                  Text(
                    selectedFile != null
                        ? selectedFile!.files.single.name
                        : "Upload Images, PDF, XLS, Video files",
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: [
                          'png',
                          'jpg',
                          'jpeg',
                          'pdf',
                          'xls',
                          'xlsx',
                          'mp4',
                        ],
                      );
                      if (result != null) {
                        setState(() {
                          selectedFile = result;
                        });
                      }
                    },
                    child: Text("Select files"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          ExpansionTile(
            title: Text("Step-by-step guide"),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "1. Prepare your file\n2. Click 'Select files'\n3. Click 'Upload'",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedFile == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please select a file first.")),
                    );
                    return;
                  }

                  String filePath = selectedFile!.files.single.path!;
                  String fileName = selectedFile!.files.single.name;
                  String ext =
                      extension(fileName).replaceFirst('.', '').toLowerCase();

                  MediaType contentType =
                      mimeTypes[ext] ?? MediaType('application', 'octet-stream');

                  File fileToUpload = File(filePath);

                  if (ext == 'jpg' || ext == 'jpeg') {
                    File? compressed = await compressImage(fileToUpload);
                    if (compressed != null) {
                      fileToUpload = compressed;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Image compression failed.")),
                      );
                      return;
                    }
                  }

                  setState(() => isLoading = true);

                  FormData formData = FormData.fromMap({
                    'memberId': AppPreference().getInt(PreferencesKey.member_Id),
                    'document': await MultipartFile.fromFile(
                      fileToUpload.path,
                      filename: fileName,
                      contentType: contentType,
                    ),
                  });

                  try {
                    Dio dio = Dio();
                    Response response = await dio.post(
                      'https://api.newpawanputradevelopers.com/api/documents/upload',
                      data: formData,
                      options: Options(headers: {
                        'Content-Type': 'multipart/form-data',
                      }),
                    );

                    setState(() => isLoading = false);

                    if (response.statusCode == 201) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Upload successful!")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("Upload failed: ${response.statusCode}")),
                      );
                    }
                  } catch (e) {
                    setState(() => isLoading = false);
                    if (e is DioError) {
                      print("DioError: ${e.message}");
                      print("Response: ${e.response?.data}");
                      print("Status code: ${e.response?.statusCode}");
                    } else {
                      print("Unexpected error: $e");
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}")),
                    );
                  }
                },
                child: isLoading
                    ? CircularProgressIndicator(color: kOrange)
                    : Text("Upload"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
