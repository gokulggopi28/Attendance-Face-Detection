import 'dart:developer';
import 'package:get/get.dart';
import 'package:attendance_app/utils/global_variables.dart';

class HomeController extends GetxController {
  var attendance = [].obs;

  @override
  void onInit() {
    super.onInit();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    attendance.value = await box.get('attendanceList') ?? [];
    log('Attendance List: $attendance');
  }

  Future<void> addAttendance(Map<String, dynamic> data) async {
    attendance.add(data);
    await box.put('attendanceList', attendance.toList());
    log('Attendance added: $data');
  }

  Future<void> clearAttendance() async {
    attendance.clear();
    await box.delete('attendanceList');
    log('Attendance cleared');
  }
}
