import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:attendance_app/utils/global_variables.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class HomeController extends GetxController {
  var attendance = [].obs;
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
    ),
  );
  var isProcessing = false.obs;
  final ImagePicker imagePicker = ImagePicker();
  Map<String, dynamic>? currentFaceData;

  @override
  void onInit() {
    super.onInit();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    attendance.value = await box.get('attendanceList') ?? [];
    log('Attendance List: $attendance');
  }

  Map<String, dynamic> extractFaceData(Face face) {
    return {
      'boundingBox': {
        'left': face.boundingBox.left,
        'top': face.boundingBox.top,
        'right': face.boundingBox.right,
        'bottom': face.boundingBox.bottom,
      },
      'headEulerAngleY': face.headEulerAngleY,
      'headEulerAngleZ': face.headEulerAngleZ,
      'leftEyeOpenProbability': face.leftEyeOpenProbability,
      'rightEyeOpenProbability': face.rightEyeOpenProbability,
      'smilingProbability': face.smilingProbability,
      'trackingId': face.trackingId,
    };
  }

  Future<bool> detectFace() async {
  try {
    isProcessing.value = true;
    final XFile? image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return false;

    final File imageFile = File(image.path);
    final inputImage = InputImage.fromFile(imageFile);
    final faces = await faceDetector.processImage(inputImage);

    if (faces.length != 1) {
      Get.snackbar(
        'Detection Error',
        faces.isEmpty
            ? 'No face detected. Please try again.'
            : 'Multiple faces detected. Ensure only one person is in frame.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final Face face = faces.first;
    if (face.headEulerAngleY != null &&
        (face.headEulerAngleY! < -10 || face.headEulerAngleY! > 10)) {
      Get.snackbar(
        'Detection Error',
        'Please face the camera directly',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    currentFaceData = extractFaceData(face);
    currentFaceData!['imagePath'] = imageFile.path;  
    return true;
  } catch (e) {
    log('Face detection error: $e');
    Get.snackbar(
      'Error',
      'Failed to process image. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return false;
  } finally {
    isProcessing.value = false;
  }
}


  Future<void> addAttendance(Map<String, dynamic> data) async {
  final bool faceDetected = await detectFace();
  if (!faceDetected) return;

  final completeData = {
    ...data,
    'faceData': currentFaceData,
    'imagePath': currentFaceData?['imagePath'], 
  };

  attendance.add(completeData);
  await box.put('attendanceList', attendance.toList());
  log('Attendance added: $completeData');
  currentFaceData = null;
}


  Future<void> clearAttendance() async {
    attendance.clear();
    await box.delete('attendanceList');
    log('Attendance cleared');
  }

  @override
  void onClose() {
    faceDetector.close();
    super.onClose();
  }
}