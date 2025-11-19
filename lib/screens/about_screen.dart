import 'package:flutter/material.dart';
import '../services/version_service.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Hakkında'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo ve Başlık
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bloodtype,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bir Damla Kan',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53935),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hayat Kurtaran Bağış Platformu',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'v${VersionService.versionName}',
                      style: const TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Amaç
            _buildSection(
              icon: Icons.favorite,
              title: 'Amacımız',
              content: 'Kan ihtiyacı olan hastalar ile kan bağışçılarını bir araya getirerek, '
                      'hayat kurtarıcı kan bağışlarını kolaylaştırmak ve hızlandırmaktır.',
            ),

            const SizedBox(height: 24),

            // Özellikler
            _buildSection(
              icon: Icons.star,
              title: 'Özellikler',
              content: '• Gerçek zamanlı kan talepleri\n'
                      '• Hastane bilgileri ve konumları\n'
                      '• Kan grubu uyumluluk kontrolü\n'
                      '• QR kod ile hızlı erişim\n'
                      '• Güvenli kullanıcı sistemi\n'
                      '• Bildirim sistemi',
            ),

            const SizedBox(height: 24),

            // İletişim
            _buildSection(
              icon: Icons.contact_mail,
              title: 'İletişim',
              content: 'Sorularınız, önerileriniz veya teknik destek için:\n\n'
                      '📧 E-posta: info@...........com\n'
                      '📱 WhatsApp: +90 533 ........\n'
                      '🌐 Web: www.............com',
            ),

            const SizedBox(height: 24),

            // Gizlilik
            _buildSection(
              icon: Icons.security,
              title: 'Gizlilik ve Güvenlik',
              content: 'Kullanıcı verileriniz Firebase güvenlik standartlarında korunmaktadır. '
                      'Kişisel bilgileriniz sadece kan bağışı süreçlerinde kullanılır ve '
                      'üçüncü şahıslarla paylaşılmaz.',
            ),

            const SizedBox(height: 24),

            // Yasal
            _buildSection(
              icon: Icons.gavel,
              title: 'Yasal Uyarı',
              content: 'Bu uygulama kan bağışı sürecini kolaylaştırmak amacıyla geliştirilmiştir. '
                      'Kan bağışı yapmadan önce mutlaka ilgili hastane veya sağlık kuruluşu '
                      'ile iletişime geçiniz.',
            ),

            const SizedBox(height: 40),

            // Footer
            Center(
              child: Column(
                children: [
                  const Text(
                    'Geliştirici',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53935),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kan Bağışı Platformu Ekibi',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.favorite, color: Colors.red.shade400),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Bir damla kan, bir hayat...\nPaylaştığınız her bilgi bir umut olabilir.',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Versiyon Bilgisi Widget'ı
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline, 
                                   color: Colors.grey.shade600, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Uygulama v${VersionService.versionName}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Build ${VersionService.buildNumber} • 6 Kasım 2025',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFE53935), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53935),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}