/// Model representing an internship seeker's full profile details.
class UserProfile {
  String fullName;
  String email;
  String phone;
  String countryCode;
  String dateOfBirth;
  String gender;
  String location;
  String avatarAsset;

  // Education & Academic Background
  String university;
  String major;
  String degreeLevel;
  String gpa;
  String graduationYear;

  // Career & Internship Preferences
  String preferredCategory;
  List<String> targetRoles;
  String workType;

  // Skills & Resume
  List<String> skills;
  String cvFileName;
  String cvFileSize;
  String cvLastUpdated;
  List<String> projects;

  UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    this.countryCode = '+855',
    required this.dateOfBirth,
    required this.gender,
    required this.location,
    required this.avatarAsset,
    required this.university,
    required this.major,
    required this.degreeLevel,
    required this.gpa,
    required this.graduationYear,
    required this.preferredCategory,
    required this.targetRoles,
    required this.workType,
    required this.skills,
    required this.cvFileName,
    required this.cvFileSize,
    required this.cvLastUpdated,
    required this.projects,
  });
}

/// Global demo user profile for Chhouen Ratanaksombo.
UserProfile currentDemoProfile = UserProfile(
  fullName: 'Chhouen Ratanaksombo',
  email: 'chhouen.ratanaksombo@gmail.com',
  phone: '99 946 638',
  countryCode: '+855',
  dateOfBirth: '15 October 2003',
  gender: 'Male',
  location: 'Phnom Penh, Cambodia',
  avatarAsset: 'assets/images/sombo_pfp.jpg',
  university: 'CADT (Cambodia Academy of Digital Technology)',
  major: 'Computer Science & Software Engineering',
  degreeLevel: 'Bachelor Degree (Year 3)',
  gpa: '3.85 / 4.00',
  graduationYear: '2026',
  preferredCategory: 'IT',
  targetRoles: [
    'Mobile App Developer',
    'Flutter Engineer',
    'Data Analyst Intern',
    'UI/UX Designer',
  ],
  workType: 'Full-time / Hybrid Internship',
  skills: [
    'Flutter & Dart',
    'Mobile App Dev',
    'REST APIs',
    'Git & GitHub',
    'UI/UX Design',
    'Python',
    'SQL Database',
    'Firebase',
  ],
  cvFileName: 'Chhouen_Ratanaksombo_CV.pdf',
  cvFileSize: '2.4 MB',
  cvLastUpdated: 'Sep 27, 2026',
  projects: [
    'Mobile-App-Capstone (Lead Flutter Developer)',
    'Union of Youth Federations of Cambodia (UYFC Volunteer)',
  ],
);
