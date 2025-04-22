import 'package:flutter/material.dart';
import '../models/department.dart';
import 'student_list_screen.dart';

class DepartmentRoomPage extends StatefulWidget {
  const DepartmentRoomPage({super.key});

  @override
  State<DepartmentRoomPage> createState() => _DepartmentRoomPageState();
}

class _DepartmentRoomPageState extends State<DepartmentRoomPage> {
  final List<Department> departments = [
    Department(name: 'CSE', rooms: ['101', 'CS102', 'CS103', 'CS104']),
    Department(name: 'Electronics', rooms: ['EC201', 'EC202', 'EC203']),
    Department(name: 'Mechanical', rooms: ['ME301', 'ME302', 'ME303']),
    Department(name: 'Civil', rooms: ['CV401', 'CV402']),
    Department(name: 'Electrical', rooms: ['EE501', 'EE502']),
    Department(name: 'Information Tech', rooms: ['IT601', 'IT602']),
    Department(name: 'Chemical', rooms: ['CH701', 'CH702']),
    Department(name: 'Biotech', rooms: ['BT801', 'BT802']),
  ];

  String? selectedDepartment;
  String? selectedRoom;

  IconData _getDepartmentIcon(String name) {
    switch (name) {
      case 'Computer Science':
        return Icons.computer;
      case 'Electronics':
        return Icons.electrical_services;
      case 'Mechanical':
        return Icons.settings;
      case 'Civil':
        return Icons.apartment;
      case 'Electrical':
        return Icons.bolt;
      case 'Information Tech':
        return Icons.devices;
      case 'Chemical':
        return Icons.science;
      case 'Biotech':
        return Icons.biotech;
      default:
        return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Department and Room")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Select Department", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: departments.map((dept) {
                  final isSelected = selectedDepartment == dept.name;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDepartment = dept.name;
                        selectedRoom = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(_getDepartmentIcon(dept.name), color: Colors.blue),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(dept.name, style: const TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            if (selectedDepartment != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Room", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: departments
                        .firstWhere((d) => d.name == selectedDepartment!)
                        .rooms
                        .map((room) {
                      final isRoomSelected = selectedRoom == room;
                      return ChoiceChip(
                        label: Text(room),
                        selected: isRoomSelected,
                        onSelected: (_) {
                          setState(() {
                            selectedRoom = room;
                          });
                        },
                        selectedColor: Colors.blue.shade300,
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(
                          color: isRoomSelected ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: (selectedDepartment != null && selectedRoom != null)
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentListScreen(
                      department: selectedDepartment!,
                      room: selectedRoom!,
                    ),
                  ),
                );
              }
                  : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text("Continue"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
