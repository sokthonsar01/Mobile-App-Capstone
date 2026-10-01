import 'dart:convert';

import 'package:interna/config/api_client.dart';
import 'package:interna/features/profile/data/student_profile.model.dart';

class StudentRepository {


  static Future<StudentProfile?> getMyProfile() async{
    final response = await ApiClient.get('/student/profile/me');
    if(response.statusCode == 404) return null ;
    if(response.statusCode!=200){
      throw Exception("Failed To Load Profile: ${response.statusCode}");
    }

    final date = jsonDecode(response.body);
    return StudentProfile.fromJson(date as Map<String,dynamic>);
  }


  static Future<StudentProfile> createProfile( Map<String , dynamic> body)async{

    final response = await ApiClient.post('/student/profile', body);

    if(response.statusCode !=201){
      throw Exception("Failed to create Profile ${response.statusCode}");
    }

    return StudentProfile.fromJson(jsonDecode(response.body));
  }

  static Future<StudentProfile> updateProfile(Map<String,dynamic> body) async{
    final response = await ApiClient.patch('/student/profile', body);

    if(response.statusCode!=200){
      throw Exception("Failed to Update Profile ${response.statusCode}");
    }

  return StudentProfile.fromJson(jsonDecode(response.body));

  }

  static Future<void> deleteStudentProfile() async{
    final response =  await ApiClient.delete('/student/profile');
    if(response.statusCode!=200){
      throw Exception("Failed To Delete Profile ${response.statusCode}");
    }
  }


}