import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:interna/features/company/data/company_model.dart';

void main() {
  group('Company Backend Contract & Schema Tests', () {
    test('Company.fromJson maps NestJS entity schema accurately', () {
      final json = {
        'id': 'f0bf5401-1f89-401d-ae65-a27578df37ad',
        'userId': 'dd35d724-3fd8-4426-a980-df4de3d18b99',
        'name': 'SEBA Banking Group',
        'logoUrl': 'https://example.com/logo.png',
        'website': 'https://sebabanking.com',
        'contact': '+85512345678',
        'industry': 'Banking & Finance',
        'description': 'Leading fintech & banking enterprise in Cambodia.',
        'verified': true,
        'createdAt': '2026-08-30T17:16:03.789Z',
        'updatedAt': '2026-08-30T17:16:03.789Z',
        '_count': {'internships': 3},
      };

      final company = Company.fromJson(json);

      expect(company.id, 'f0bf5401-1f89-401d-ae65-a27578df37ad');
      expect(company.name, 'SEBA Banking Group');
      expect(company.logoUrl, 'https://example.com/logo.png');
      expect(company.website, 'https://sebabanking.com');
      expect(company.contact, '+85512345678');
      expect(company.industry, 'Banking & Finance');
      expect(company.description, contains('Leading fintech'));
      expect(company.verified, true);
      expect(company.internshipCount, 3);
    });

    test('Live Backend /company returns HTTP 200 with database records', () async {
      final url = Uri.parse('http://localhost:3000/company');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Bypass-Tunnel-Reminder': 'true',
        },
      );

      // ignore: avoid_print
      print('STATUS: ${response.statusCode}');

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body);
      expect(body, contains('data'));
      expect(body, contains('meta'));

      final List companies = body['data'];
      expect(companies.isNotEmpty, true);
      final firstCompany =
          Company.fromJson(companies.first as Map<String, dynamic>);
      expect(firstCompany.id.isNotEmpty, true);
      expect(firstCompany.name.isNotEmpty, true);
    });
  });
}
