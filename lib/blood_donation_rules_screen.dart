import 'package:flutter/material.dart';

class BloodDonationRulesScreen extends StatelessWidget {
  const BloodDonationRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Kan Bağışı Kuralları'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.health_and_safety,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kan Bağışı Kuralları ve Şartları',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53935),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Güvenli kan bağışı için uymanız gereken kurallar',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Genel Şartlar
              _buildSectionCard(
                icon: Icons.fact_check,
                title: '📋 Genel Şartlar',
                content: [
                  {
                    'title': '🎂 Yaş Sınırı',
                    'description': '18-65 yaş arası (ilk kez bağış yapacaklar için 61 yaşından gün almamış olmak)'
                  },
                  {
                    'title': '⚖️ Ağırlık',
                    'description': 'En az 50 kg olmalıdır'
                  },
                  {
                    'title': '🏥 Sağlık Durumu',
                    'description': 'Genel sağlık durumunun iyi olması, kan bağışına engel teşkil edecek bir hastalığın bulunmaması'
                  },
                  {
                    'title': '🔬 Taramalar',
                    'description': 'Fiziksel muayeneden geçmek ve tansiyon, nabız, hemoglobin değerlerinin uygun aralıkta olması'
                  },
                ],
              ),

              const SizedBox(height: 24),

              // Dikkat Edilmesi Gerekenler
              _buildSectionCard(
                icon: Icons.warning_amber,
                title: '⚠️ Dikkat Edilmesi Gerekenler',
                content: [
                  {
                    'title': '😴 Yorgunluk ve Uykusuzluk',
                    'description': 'Kan bağışı yapacak kişinin aşırı yorgun veya uykusuz olmaması gerekir'
                  },
                  {
                    'title': '🚭 Alkol ve Sigara',
                    'description': 'Bağıştan en az 24 saat önce alkol, 1 saat önce ise sigara içilmemelidir'
                  },
                  {
                    'title': '🍎 Beslenme',
                    'description': 'Kan vermeden önce yağlı gıdalardan kaçınılmalı ve bol sıvı tüketilmelidir. Aç karnına kan vermek yerine hafif bir şeyler atıştırarak gitmek daha iyidir'
                  },
                  {
                    'title': '💊 İlaç Kullanımı',
                    'description': 'Kan vermeye engel olabilecek ilaçlar (aspirin gibi ağrı kesiciler vb.) kullanılıyorsa, kan merkezine danışılmalıdır'
                  },
                  {
                    'title': '📅 Bağış Aralığı',
                    'description': 'Erkekler için 90 gün, kadınlar için 120 gün (özel durumlarda hekim tarafından düzenlenebilir)'
                  },
                ],
              ),

              const SizedBox(height: 24),

              // Kimler Kan Veremez
              _buildSectionCard(
                icon: Icons.cancel,
                title: '❌ Kimler Kan Veremez?',
                content: [
                  {
                    'title': '🦠 Enfeksiyöz Hastalıklar',
                    'description': 'Hepatit B veya C, AIDS gibi ciddi hastalıkları geçirmiş veya geçirmekte olanlar'
                  },
                  {
                    'title': '🫁 Kronik Hastalıklar',
                    'description': 'Kronik bronşit, otoimmün hastalıklar, kronik böbrek hastalığı gibi rahatsızlıkları olanlar'
                  },
                  {
                    'title': '🩸 Kanama Bozuklukları',
                    'description': 'Kanama eğilimi olan kişiler'
                  },
                ],
              ),

              const SizedBox(height: 32),

              // Önemli Not
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.orange.shade200,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info,
                      color: Colors.orange,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Önemli Not',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kan bağışı yapmadan önce mutlaka sağlık personeli ile görüşün. '
                      'Herhangi bir sağlık sorununuz varsa veya düzenli ilaç kullanıyorsanız, '
                      'kan bağışı yapabilirliğiniz konusunda doktorunuza danışın.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade800,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // İletişim Butonu
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📞 Kan bağışı hattı: ****'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.phone),
                    label: const Text(
                      'Kan Bağışı Hattı: ******',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Map<String, String>> content,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFFE53935),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 16),
            
            // Content Items
            ...content.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}