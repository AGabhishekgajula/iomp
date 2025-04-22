import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/student_service.dart';
import 'live_face_verification_screen.dart';

class StudentListScreen extends StatefulWidget {
  final String department;
  final String room;

  const StudentListScreen({
    Key? key,
    required this.department,
    required this.room,
  }) : super(key: key);

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Student> students = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    try {
      final fetchedStudents = await StudentService.fetchStudents(widget.department, widget.room);
      setState(() {
        students = fetchedStudents;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _handleVerificationResult(String rollNumber, bool isVerified) {
    setState(() {
      final student = students.firstWhere((s) => s.rollNumber == rollNumber);
      student.isVerified = isVerified;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Students in ${widget.department} - ${widget.room}"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text("Error: $error"))
          : ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: CircleAvatar(child: Text(student.name[0])),
              title: Text(student.name),
              subtitle: Text("Roll No: ${student.rollNumber}"),
              trailing: ElevatedButton.icon(
                icon: Icon(student.isVerified ? Icons.check : Icons.verified_user),
                label: Text(student.isVerified ? "Verified" : "Verify"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: student.isVerified ? Colors.green : Colors.blue,
                ),
                onPressed: student.isVerified
                    ? null
                    : () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LiveFaceVerificationScreen(
                        student: student,
                      ),
                    ),
                  );

                  if (result == true) {
                    _handleVerificationResult(student.rollNumber, true);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
