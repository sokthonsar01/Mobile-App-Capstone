class StudentProfile{
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final DateTime? dob; // date of birth
  final String gender;
  final String currentAddress;
  final String? description;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // constructor
  const StudentProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.userId,
    this.dob,
    this.gender = "OTHER",
    required this.currentAddress,
    this.description,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt
  });

  String get getFullName => '$firstName $lastName'.trim();

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic d) =>
        d != null ? DateTime.tryParse(d.toString()) : null;
    return StudentProfile(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      dob: parseDate(json['dob']),
      gender: json['gender']?.toString() ?? 'OTHER',
      currentAddress: json['currentAddress']?.toString() ?? '',
      description: json['description']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'firstName': firstName,
      'lastName':lastName,
      if(dob !=null) 'dob' : dob!.toIso8601String(),
      'gender' : gender.toUpperCase(),
      'currentAddress':currentAddress,
      if(description!=null) 'description': description,
      if(avatarUrl!=null) 'avatarUrl' : avatarUrl
    }; 
  }// end func
} // end class 