// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:excel/excel.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../models/student.dart';
//
// class AttendanceSummaryScreen extends StatelessWidget {
//   final List<Student> students;
//
//   const AttendanceSummaryScreen({super.key, required this.students});
//
//   Future<void> exportToExcel(BuildContext context) async {
//     // Ask for storage permission
//     var status = await Permission.storage.request();
//     if (!status.isGranted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Storage permission denied")),
//       );
//       return;
//     }
//
//     final verifiedStudents = students.where((s) => s.isVerified).toList();
//
//     final excel = Excel.createExcel();
//     final sheet = excel['Attendance'];
//
//     // Header row
//     sheet.appendRow(['Roll Number', 'Name', 'Verification Status']);
//
//     for (final student in students) {
//       sheet.appendRow([
//         student.rollNumber,
//         student.name,
//         student.isVerified ? 'Present' : 'Absent',
//       ]);
//     }
//
//     final directory = await getExternalStorageDirectory();
//     final path = '${directory!.path}/attendance_summary.xlsx';
//     final fileBytes = excel.encode();
//     final file = File(path)
//       ..createSync(recursive: true)
//       ..writeAsBytesSync(fileBytes!);
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Excel file saved to $path")),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final verifiedCount = students.where((s) => s.isVerified).length;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Attendance Summary")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(
//               "Total Students: ${students.length}",
//               style: const TextStyle(fontSize: 18),
//             ),
//             Text(
//               "Verified (Present): $verifiedCount",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: ListView.separated(
//                 itemCount: students.length,
//                 separatorBuilder: (_, __) => const Divider(),
//                 itemBuilder: (context, index) {
//                   final student = students[index];
//                   return ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: student.isVerified ? Colors.green : Colors.red,
//                       child: Icon(student.isVerified ? Icons.check : Icons.close, color: Colors.white),
//                     ),
//                     title: Text(student.name),
//                     subtitle: Text("Roll No: ${student.rollNumber}"),
//                     trailing: Text(student.isVerified ? "Present" : "Absent"),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: () => exportToExcel(context),
//               icon: const Icon(Icons.download),
//               label: const Text("Export to Excel"),
//               style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
