import 'dart:io';
import 'package:attendance_app/app/modules/home/views/add_attendance_view.dart';
import 'package:attendance_app/app/modules/home/views/employee_details_view.dart';
import 'package:attendance_app/utils/face_detector_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Attendance App',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () async {
                await controller.clearAttendance();
              },
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.camera_alt),
                text: 'Scan',
              ),
              Tab(
                icon: Icon(Icons.people),
                text: 'Employees',
              ),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            const FaceDetectorView(),
            // Container(
            //   decoration: const BoxDecoration(
            //     gradient: LinearGradient(
            //       colors: [Colors.white, Color(0xFFE0F7FA)],
            //       begin: Alignment.topCenter,
            //       end: Alignment.bottomCenter,
            //     ),
            //   ),
            //   child: Center(
            //     child: Obx(() {
            //       if (controller.isProcessing.value) {
            //         return const CircularProgressIndicator();
            //       }

            //       if (controller.matchedEmployee.value != null) {
            //         Future.delayed(const Duration(seconds: 5), () {
            //           controller.clearMatchedEmployee();
            //         });

            //         final employee = controller.matchedEmployee.value!;
            //         return Column(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             if (employee['imagePath'] != null)
            //               Container(
            //                 width: 200,
            //                 height: 200,
            //                 margin: const EdgeInsets.only(bottom: 16),
            //                 decoration: BoxDecoration(
            //                   borderRadius: BorderRadius.circular(100),
            //                   image: DecorationImage(
            //                     image: FileImage(File(employee['imagePath'])),
            //                     fit: BoxFit.cover,
            //                   ),
            //                 ),
            //               ),
            //             Text(
            //               employee['name'] ?? 'Unknown',
            //               style: const TextStyle(
            //                 fontSize: 24,
            //                 fontWeight: FontWeight.bold,
            //                 color: Color(0xFF2193b0),
            //               ),
            //             ),
            //             const SizedBox(height: 8),
            //             Text(
            //               employee['designation'] ?? '',
            //               style: const TextStyle(
            //                 fontSize: 18,
            //                 color: Colors.grey,
            //               ),
            //             ),
            //             const SizedBox(height: 16),
            //             Text(
            //               'Match Found!',
            //               style: TextStyle(
            //                 fontSize: 16,
            //                 color: Colors.green[600],
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //           ],
            //         );
            //       }

            //       return ElevatedButton.icon(
            //         onPressed: controller.scanAndCompareFace,
            //         icon: const Icon(Icons.camera_alt),
            //         label: const Text('Scan Face'),
            //         style: ElevatedButton.styleFrom(
            //           padding: const EdgeInsets.symmetric(
            //               horizontal: 32, vertical: 16),
            //           backgroundColor: const Color(0xFF2193b0),
            //         ),
            //       );
            //     }),
            //   ),
            // ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFE0F7FA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Obx(() => ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: controller.attendance.length,
                    itemBuilder: (context, index) {
                      final record = controller.attendance[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [Colors.white, const Color(0xFFE1F5FE)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              final Map<dynamic, dynamic> data =
                                  controller.attendance[index];
                              Get.to(() =>
                                  EmployeeDetailsView(employeeData: data));
                            },
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              record['name'] ?? 'No Name',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF2193b0),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      record['date'] ?? 'No Date',
                                      style: const TextStyle(
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.work,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      record['designation'] ?? 'No Designation',
                                      style: const TextStyle(
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2193b0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                record['status'] ?? 'No Status',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: FloatingActionButton(
              onPressed: () {
                Get.to(() => const AddAttendanceView());
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
