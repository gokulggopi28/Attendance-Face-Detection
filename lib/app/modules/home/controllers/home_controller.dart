import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:attendance_app/utils/global_variables.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class HomeController extends GetxController {
  var attendance = [].obs;
  var isProcessing = false.obs;
  final matchedEmployee = Rxn<Map<dynamic, dynamic>>();
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
    ),
  );
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
        faces.isEmpty ? 'No face detected. Please try again.' : 'Multiple faces detected. Ensure only one person is in frame.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final Face face = faces.first;
    if (face.headEulerAngleY != null && (face.headEulerAngleY! < -10 || face.headEulerAngleY! > 10)) {
      Get.snackbar(
        'Detection Error',
        'Please face the camera directly',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    currentFaceData = extractFaceData(face);
    currentFaceData!['imagePath'] = imageFile.path;

   
    log('Scanned Face Data: $currentFaceData');

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

Future<void> scanAndCompareFace() async {
  try {
    isProcessing.value = true;
    matchedEmployee.value = null;
    currentFaceData = null;

    final bool faceDetected = await detectFace();
    if (!faceDetected) {
      isProcessing.value = false;
      return;
    }

    double bestMatchScore = 0;
    Map<dynamic, dynamic>? bestMatch;

    for (var employee in attendance) {
      final storedFaceData = employee['faceData'];
      if (storedFaceData is Map<String, dynamic>) {
        
        log('Stored Face Data for ${employee['name']}: $storedFaceData');

        final double similarity = compareFaces(
          currentFaceData!,
          storedFaceData,
        );

       
        log('Comparison Score with ${employee['name']}: $similarity');

        if (similarity > bestMatchScore && similarity > 0.60) { 
          bestMatchScore = similarity;
          bestMatch = employee;
        }
      }
    }

    if (bestMatch != null) {
      matchedEmployee.value = bestMatch;
      Get.snackbar(
        'Match Found!',
        'Employee: ${bestMatch['name']}',
        backgroundColor: const Color(0xFF2193b0),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'No Match Found',
        'No matching employee found in the database',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  } catch (e) {
    log('Face comparison error: $e');
    Get.snackbar(
      'Error',
      'An error occurred while comparing faces',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  } finally {
    isProcessing.value = false;
    currentFaceData = null;
  }
}


  double compareFaces(Map<String, dynamic> face1, Map<String, dynamic> face2) {
    double similarity = 0;
    int totalFeatures = 0;

    // Compare bounding box proportions
    final box1 = face1['boundingBox'];
    final box2 = face2['boundingBox'];

    final width1 = box1['right'] - box1['left'];
    final height1 = box1['bottom'] - box1['top'];
    final width2 = box2['right'] - box2['left'];
    final height2 = box2['bottom'] - box2['top'];

    final aspectRatio1 = width1 / height1;
    final aspectRatio2 = width2 / height2;

    if ((aspectRatio1 - aspectRatio2).abs() < 0.2) {
      similarity += 1;
    }
    totalFeatures++;

    // Compare head angles
    if (face1['headEulerAngleY'] != null && face2['headEulerAngleY'] != null) {
      if ((face1['headEulerAngleY'] - face2['headEulerAngleY']).abs() < 10) {
        similarity += 1;
      }
      totalFeatures++;
    }

    if (face1['headEulerAngleZ'] != null && face2['headEulerAngleZ'] != null) {
      if ((face1['headEulerAngleZ'] - face2['headEulerAngleZ']).abs() < 5) {
        similarity += 1;
      }
      totalFeatures++;
    }

    // Compare eye probabilities
    if (face1['leftEyeOpenProbability'] != null &&
        face2['leftEyeOpenProbability'] != null) {
      if ((face1['leftEyeOpenProbability'] - face2['leftEyeOpenProbability'])
              .abs() <
          0.3) {
        similarity += 1;
      }
      totalFeatures++;
    }

    if (face1['rightEyeOpenProbability'] != null &&
        face2['rightEyeOpenProbability'] != null) {
      if ((face1['rightEyeOpenProbability'] - face2['rightEyeOpenProbability'])
              .abs() <
          0.2) {
        similarity += 1;
      }
      totalFeatures++;
    }

    if (face1['smilingProbability'] != null &&
        face2['smilingProbability'] != null) {
      if ((face1['smilingProbability'] - face2['smilingProbability']).abs() <
          0.2) {
        similarity += 1;
      }
      totalFeatures++;
    }

    return totalFeatures > 0 ? similarity / totalFeatures : 0;
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
    log('Updated Attendance List: $attendance');
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

  void clearMatchedEmployee() {
    matchedEmployee.value = null;
  }
  
}


