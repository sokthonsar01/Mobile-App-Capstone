import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:interna/config/app_env.dart';
import 'package:interna/features/home/data/internship_model.dart';

void main() {
  group('Backend Contract & Live Connection Tests', () {
    test('InternshipOpportunity.fromJson maps backend payload correctly', () {
      final mockBackendJson = {
        'id': 'test-uuid-001',
        'companyId': 'comp-uuid-001',
        'title': 'Software Engineering Intern',
        'description': 'Building next-generation apps',
        'location': 'Phnom Penh',
        'responsibilities': 'Develop features and write unit tests',
        'requirements': 'Degree in CS or related field',
        'position': 2,
        'type': 'REMOTE',
        'deadline': '2026-10-30T00:00:00.000Z',
        'status': 'OPEN',
        'stipend': '\$250 - \$400 / month',
        'company': {
          'id': 'comp-uuid-001',
          'name': 'Chip Mong Group',
          'logoUrl': null,
          'verified': true,
        },
        'requiredSkills': [
          {
            'skill': {
              'name': 'Flutter',
              'category': 'Mobile',
            }
          }
        ]
      };

      final opportunity = InternshipOpportunity.fromJson(mockBackendJson);

      expect(opportunity.id, 'test-uuid-001');
      expect(opportunity.role, 'Software Engineering Intern');
      expect(opportunity.company, 'Chip Mong Group');
      expect(opportunity.schedule, 'REMOTE Internship');
      expect(opportunity.paymentStatus, 'Payment Included');
      expect(opportunity.deadline, '2026-10-30');
      expect(opportunity.requirements, ['Flutter']);
      expect(opportunity.brandColor, const Color(0xFFE91E63));
      expect(opportunity.logoKey, 'chip_mong');
    });

    test('Live Backend /internships endpoint connectivity and contract', () async {
      final url = Uri.parse('${AppEnv.apiBaseUrl}/internships');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Bypass-Tunnel-Reminder': 'true',
        },
      );

      // Print status matching integrati
      //on plan specification
      // ignore: avoid_print
      print('STATUS: ${response.statusCode}');

      expect(response.statusCode, 200);

      final data = jsonDecode(response.body);
      expect(data, contains('data'));
      expect(data, contains('meta'));
    });
  });
}
