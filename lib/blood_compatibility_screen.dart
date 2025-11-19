import 'package:flutter/material.dart';

class BloodCompatibilityScreen extends StatelessWidget {
  const BloodCompatibilityScreen({super.key});

  // Kan grupları uyumluluk bilgileri
  final Map<String, Map<String, dynamic>> bloodCompatibility = const {
    'A+': {
      'canDonateTo': ['A+', 'AB+'],
      'canReceiveFrom': ['A+', 'A-', 'O+', 'O-'],
      'description': 'A+ kan grubu sahipleri A+ ve AB+ kan gruplarına kan verebilir.'
    },
    'A-': {
      'canDonateTo': ['A+', 'A-', 'AB+', 'AB-'],
      'canReceiveFrom': ['A-', 'O-'],
      'description': 'A- kan grubu sahipleri tüm A ve AB kan gruplarına kan verebilir.'
    },
    'B+': {
      'canDonateTo': ['B+', 'AB+'],
      'canReceiveFrom': ['B+', 'B-', 'O+', 'O-'],
      'description': 'B+ kan grubu sahipleri B+ ve AB+ kan gruplarına kan verebilir.'
    },
    'B-': {
      'canDonateTo': ['B+', 'B-', 'AB+', 'AB-'],
      'canReceiveFrom': ['B-', 'O-'],
      'description': 'B- kan grubu sahipleri tüm B ve AB kan gruplarına kan verebilir.'
    },
    'AB+': {
      'canDonateTo': ['AB+'],
      'canReceiveFrom': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
      'description': 'AB+ evrensel alıcı, herkesten kan alabilir ama sadece AB+ grubuna verebilir.'
    },
    'AB-': {
      'canDonateTo': ['AB+', 'AB-'],
      'canReceiveFrom': ['A-', 'B-', 'AB-', 'O-'],
      'description': 'AB- kan grubu sahipleri AB+ ve AB- kan gruplarına kan verebilir.'
    },
    'O+': {
      'canDonateTo': ['A+', 'B+', 'AB+', 'O+'],
      'canReceiveFrom': ['O+', 'O-'],
      'description': 'O+ kan grubu sahipleri tüm pozitif kan gruplarına kan verebilir.'
    },
    'O-': {
      'canDonateTo': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
      'canReceiveFrom': ['O-'],
      'description': 'O- evrensel verici, herkese kan verebilir ama sadece O- grubundan kan alabilir.'
    },
  };

  Color _getBloodTypeColor(String bloodType) {
    switch (bloodType) {
      case 'A+':
      case 'A-':
        return Colors.red;
      case 'B+':
      case 'B-':
        return Colors.blue;
      case 'AB+':
      case 'AB-':
        return Colors.purple;
      case 'O+':
      case 'O-':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Kan Uyumluluğu'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve açıklama
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade600, Colors.red.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bloodtype,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kan Grubu Uyumluluğu',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Hangi kan grubu kime kan verebilir?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kan bağışı yaparken kan grubu uyumluluğu hayati önem taşır. Aşağıda her kan grubunun kimlere kan verebileceği ve kimlerden kan alabileceği detaylı olarak açıklanmıştır.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Evrensel verici ve alıcı bilgileri
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.volunteer_activism, color: Colors.orange.shade600, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Evrensel Verici',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'O-',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Herkese kan verebilir',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.favorite, color: Colors.purple.shade600, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Evrensel Alıcı',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade600,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'AB+',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Herkesten kan alabilir',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Kan grupları listesi
              Text(
                'Kan Grubu Detayları',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),

              const SizedBox(height: 16),

              ...bloodCompatibility.entries.map((entry) {
                String bloodType = entry.key;
                Map<String, dynamic> compatibility = entry.value;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getBloodTypeColor(bloodType),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          bloodType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      '$bloodType Kan Grubu',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      compatibility['description'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kan verebileceği gruplar
                            const Text(
                              '✅ Kan Verebileceği Gruplar:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (compatibility['canDonateTo'] as List<String>)
                                  .map((group) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.green.shade300),
                                        ),
                                        child: Text(
                                          group,
                                          style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),

                            const SizedBox(height: 16),

                            // Kan alabileceği gruplar
                            const Text(
                              '🩸 Kan Alabileceği Gruplar:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (compatibility['canReceiveFrom'] as List<String>)
                                  .map((group) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.red.shade300),
                                        ),
                                        child: Text(
                                          group,
                                          style: TextStyle(
                                            color: Colors.red.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Önemli bilgiler
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Önemli Bilgiler',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Kan bağışı yapmadan önce mutlaka doktor kontrolünden geçiniz\n'
                      '• Acil durumlarda kan uyumluluğu hayati önem taşır\n'
                      '• O- grubu acil durumlarda en çok ihtiyaç duyulan kan grubudur\n'
                      '• AB+ grubu nadiren kan bağışçısı aranır çünkü herkesten kan alabilir\n'
                      '• Kan verme aralığı erkekler için 3 ay, kadınlar için 4 aydır',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}