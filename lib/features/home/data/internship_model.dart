import 'package:flutter/material.dart';

/// One internship opportunity displayed in the home dashboard.
class InternshipOpportunity {
  final String id;
  final String role;
  final String company;
  final String category;
  final String location;
  final String schedule;
  final String paymentStatus;
  final String deadline;
  final Color brandColor;
  final String logoKey;
  final String description;
  final List<String> requirements;
  final String stipend;
  final bool isSaved;

  const InternshipOpportunity({
    required this.id,
    required this.role,
    required this.company,
    required this.category,
    required this.location,
    required this.schedule,
    required this.paymentStatus,
    required this.deadline,
    required this.brandColor,
    required this.logoKey,
    required this.description,
    required this.requirements,
    this.stipend = '\$200 - \$350 / month',
    this.isSaved = false,
  });

  /// Full display title like "Marketing Intern at Chip Mong"
  String get displayTitle => '$role at $company';

  /// Path to the company logo PNG image asset.
  String get logoAssetPath {
    switch (logoKey) {
      case 'chip_mong':
        return 'assets/images/logos/Chigmong logo.png';
      case 'canadia':
        return 'assets/images/logos/Canada bank logo.png';
      case 'cellcard':
        return 'assets/images/logos/Cellcard logo.png';
      case 'aba':
        return 'assets/images/logos/ABA Logo.png';
      case 'smart':
        return 'assets/images/logos/smart logo.png';
      case 'hanuman':
        return 'assets/images/logos/Hanuman beer logo.png';
      case 'meoys':
        return 'assets/images/logos/Moeys Logo.png';
      default:
        return 'assets/images/main_logo.png';
    }
  }

  /// Path to the 750x350 card poster PNG image asset.
  String get posterAssetPath {
    switch (logoKey) {
      case 'chip_mong':
        return 'assets/images/posters/Chigmong card 750 x 350.png';
      case 'canadia':
        return 'assets/images/posters/Canada bank card 750 x 350.png';
      case 'cellcard':
        return 'assets/images/posters/Cellcard card 750 x 350.png';
      case 'aba':
        return 'assets/images/posters/aba card 750 x 350.png';
      case 'smart':
        return 'assets/images/posters/Smart card  750 x 350.png';
      case 'hanuman':
        return 'assets/images/posters/hanuman card 750 x 350.png';
      case 'meoys':
        return 'assets/images/posters/Moeys card 750 x 350.png';
      default:
        return '';
    }
  }

  /// Path to the 1280x480 wide banner poster PNG image asset.
  String get bannerPosterAssetPath {
    switch (logoKey) {
      case 'chip_mong':
        return 'assets/images/posters/Chipmong card 1280 x 480.png';
      case 'canadia':
        return 'assets/images/posters/Canada bank Card 1280 x 480.png';
      case 'cellcard':
        return 'assets/images/posters/Cellcard card 1280 x 480.png';
      case 'aba':
        return 'assets/images/posters/aba Card 1280 x 480.png';
      case 'smart':
        return 'assets/images/posters/smart card 1280 x 480.png';
      case 'hanuman':
        return 'assets/images/posters/Hanuman Card 1280 x 480 (2).png';
      case 'meoys':
        return 'assets/images/posters/Moeys card 1280 x 480.png';
      default:
        return '';
    }
  }

  InternshipOpportunity copyWith({
    String? id,
    String? role,
    String? company,
    String? category,
    String? location,
    String? schedule,
    String? paymentStatus,
    String? deadline,
    Color? brandColor,
    String? logoKey,
    String? description,
    List<String>? requirements,
    String? stipend,
    bool? isSaved,
  }) {
    return InternshipOpportunity(
      id: id ?? this.id,
      role: role ?? this.role,
      company: company ?? this.company,
      category: category ?? this.category,
      location: location ?? this.location,
      schedule: schedule ?? this.schedule,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deadline: deadline ?? this.deadline,
      brandColor: brandColor ?? this.brandColor,
      logoKey: logoKey ?? this.logoKey,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      stipend: stipend ?? this.stipend,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

/// Demo list of internships matching the dashboard mockup.
const List<InternshipOpportunity> demoInternships = [
  InternshipOpportunity(
    id: 'cm-01',
    role: 'Marketing Intern',
    company: 'Chip Mong',
    category: 'Marketing',
    location: 'Street 123, Khan Sen Sok, Phnom Penh',
    schedule: 'Full-Time: 8:00 AM - 5:00 PM',
    paymentStatus: 'Payment Included',
    deadline: 'February 14, 2026',
    brandColor: Color(0xFFE91E63),
    logoKey: 'chip_mong',
    description:
        'Join the Chip Mong Retail dynamic marketing team to assist with digital campaigns, content creation, social media engagement, and seasonal promotional rollouts across retail chains in Cambodia.',
    requirements: [
      'Pursuing or completed degree in Marketing, Communications, or Business.',
      'Familiarity with Canva, Photoshop, or social media management tools.',
      'Strong communication skills in Khmer and English.',
      'Eager to learn fast-paced retail marketing operations.',
    ],
    stipend: '\$250 - \$350 / month',
  ),
  InternshipOpportunity(
    id: 'canadia-02',
    role: 'Finance Intern',
    company: 'Canadia Bank',
    category: 'Finance',
    location: 'Street 134, Khan Toul Kork, Phnom Penh',
    schedule: 'Full-Time: 8:00 AM - 5:00 PM',
    paymentStatus: 'Payment Included',
    deadline: 'February 23, 2026',
    brandColor: Color(0xFFC62828),
    logoKey: 'canadia',
    description:
        'Gain hands-on corporate banking and financial analysis experience with Canadia Bank, supporting daily reconciliations, customer financial reporting, and credit assessment documentation.',
    requirements: [
      'Undergraduate or fresh graduate in Banking, Finance, or Accounting.',
      'Proficiency in Microsoft Excel and basic accounting principles.',
      'High attention to detail and analytical problem-solving mindset.',
      'Ability to maintain confidential financial data integrity.',
    ],
    stipend: '\$280 - \$400 / month',
  ),
  InternshipOpportunity(
    id: 'cellcard-03',
    role: 'AI Specialist Intern',
    company: 'Cellcard',
    category: 'Tech',
    location: 'Street 123, Khan Sen Sok, Phnom Penh',
    schedule: 'Full-Time: 8:00 AM - 5:00 PM',
    paymentStatus: 'Payment Included',
    deadline: 'February 14, 2026',
    brandColor: Color(0xFFFF9800),
    logoKey: 'cellcard',
    description:
        'Work alongside Cellcard Royal Group AI & Innovation engineering teams to develop intelligent chatbot workflows, predictive analytics models for telecom networks, and automated data pipelines.',
    requirements: [
      'Studying Computer Science, Artificial Intelligence, or Data Engineering.',
      'Hands-on experience with Python, PyTorch/TensorFlow, and REST APIs.',
      'Understanding of LLMs, NLP, and machine learning fundamentals.',
      'Passionate about telecommunications digital transformation.',
    ],
    stipend: '\$300 - \$450 / month',
  ),
  InternshipOpportunity(
    id: 'aba-04',
    role: 'Finance Intern',
    company: 'ABA',
    category: 'Finance',
    location: 'Street 123, Khan Sen Sok, Phnom Penh',
    schedule: 'Full-Time: 8:00 AM - 5:00 PM',
    paymentStatus: 'Payment Included',
    deadline: 'February 14, 2026',
    brandColor: Color(0xFF003D6B),
    logoKey: 'aba',
    description:
        'Experience modern fintech banking with ABA Bank. Collaborate with the financial operations and risk management departments to audit digital transactions, analyze merchant trends, and compile audit reports.',
    requirements: [
      'Degree in Finance, Economics, Banking, or related discipline.',
      'Strong quantitative reasoning and spreadsheet skills.',
      'Knowledge of digital banking and cashless payment ecosystems.',
      'Good teamwork spirit and prompt communication.',
    ],
    stipend: '\$270 - \$380 / month',
  ),
  InternshipOpportunity(
    id: 'smart-05',
    role: 'UX/UI Intern',
    company: 'Smart',
    category: 'Design',
    location: 'Street 123, Khan Sen Sok, Phnom Penh',
    schedule: 'Full-Time: 8:00 AM - 5:00 PM',
    paymentStatus: 'Payment Included',
    deadline: 'February 14, 2026',
    brandColor: Color(0xFF2E7D32),
    logoKey: 'smart',
    description:
        'Shape the digital experiences for millions of Smart Axiata subscribers. Design mobile user journeys, conduct usability testing, create interactive Figma prototypes, and contribute to design systems.',
    requirements: [
      'Portfolio displaying mobile or web interface design projects.',
      'Proficiency in Figma, auto-layout, design tokens, and prototyping.',
      'Understanding of user-centric research and accessibility principles.',
      'Creative mindset with enthusiasm for modern app trends.',
    ],
    stipend: '\$260 - \$370 / month',
  ),
  InternshipOpportunity(
    id: 'hanuman-06',
    role: 'Data Analyst Intern',
    company: 'Hanuman',
    category: 'Tech',
    location: 'Street (289), Toul Kork, Phnom Penh',
    schedule: 'Full-Time: 8:00 AM - 5:00 PM',
    paymentStatus: 'Payment Included',
    deadline: 'February 14, 2026',
    brandColor: Color(0xFF1565C0),
    logoKey: 'hanuman',
    description:
        'Analyze sales performance, estate supply chains, and market expansion metrics at Hanuman. Create automated PowerBI/Tableau dashboards and assist business teams with data-backed decisions.',
    requirements: [
      'Background in Data Science, Statistics, Mathematics, or IT.',
      'Proficiency in SQL, Python/R, and visualization tools (PowerBI/Tableau).',
      'Curiosity for exploratory data analysis and trend forecasting.',
      'Ability to translate raw metrics into meaningful insights.',
    ],
    stipend: '\$280 - \$400 / month',
  ),
  InternshipOpportunity(
    id: 'meoys-07',
    role: 'Finance Intern',
    company: 'MEOYS',
    category: 'Finance',
    location: 'Street 123, Khan Sen Sok, Phnom Penh',
    schedule: 'Full-Time: 8:00 AM - 5:00 PM',
    paymentStatus: 'Payment Included',
    deadline: 'February 14, 2026',
    brandColor: Color(0xFFF57F17),
    logoKey: 'meoys',
    description:
        'Support financial administration, scholarship program budgeting, educational grants verification, and public sector accounting workflows within the Ministry of Education, Youth and Sport.',
    requirements: [
      'Major in Public Administration, Accounting, Finance, or Economics.',
      'Solid understanding of accounting ledger documentation.',
      'High level of integrity, punctuality, and administrative discipline.',
      'Fluency in Khmer and working knowledge of English.',
    ],
    stipend: '\$220 - \$320 / month',
  ),
];
