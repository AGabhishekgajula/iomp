class Student {
  final String name;
  final String rollNumber;
  bool isVerified;

  Student({
    required this.name,
    required this.rollNumber,
    this.isVerified = false,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['name'],
      rollNumber: json['rollNumber'],
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rollNumber': rollNumber,
      'isVerified': isVerified,
    };
  }
}
