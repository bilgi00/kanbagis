import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DataProtectionLawScreen extends StatelessWidget {
  const DataProtectionLawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Verilerin Korunması Yasası'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık Kartı
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE53935),
                      Color(0xFFD32F2F),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.shield,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kişisel Verilerin Korunması',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'KVKK Yasası ve Mevzuat Bilgileri',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Uygulama İçin KVKK Bilgileri
            _buildInfoCard(
              title: 'Bir Damla Kan Uygulaması KVKK Uyumu',
              icon: Icons.security,
              children: [
                const Text(
                  'Uygulamız, 6698 sayılı Kişisel Verilerin Korunması Kanunu\'na tam uyum sağlamaktadır.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 12),
                _buildBulletPoint('Kişisel verileriniz şifrelenmiş olarak saklanır'),
                _buildBulletPoint('Verileriniz sadece kan bağışı amacıyla kullanılır'),
                _buildBulletPoint('Üçüncü şahıslarla veri paylaşımı yapılmaz'),
                _buildBulletPoint('Veri işleme süreçleri şeffaf bir şekilde yönetilir'),
                _buildBulletPoint('Veri silme talebinizi her zaman iletebilirsiniz'),
              ],
            ),

            const SizedBox(height: 16),

            // Yasal Belgeler
            _buildInfoCard(
              title: 'Yasal Belgeler ve Kaynaklar',
              icon: Icons.description,
              children: [
                const Text(
                  'KVKK ile ilgili resmi belgeler ve mevzuat bilgilerine aşağıdaki linklerden ulaşabilirsiniz:',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),
                
                // KVKK PDF Linki
                _buildDocumentLink(
                  title: 'KVKK Yasası (PDF)',
                  subtitle: 'Kişisel Verilerin Korunması Yasası - Resmi Metin',
                  url: 'https://kvkk.gov.ct.tr/Portals/24/89-2007%20Kisisel%20Verilerin%20Korunmas%20Yasasi.pdf',
                  icon: Icons.picture_as_pdf,
                ),
                
                const SizedBox(height: 12),
                
                // Mevzuat Linki
                _buildDocumentLink(
                  title: 'KVKK Mevzuatı',
                  subtitle: '6698 Sayılı Kanun - Resmi Mevzuat',
                  url: 'https://www.mevzuat.gov.tr/mevzuat?MevzuatNo=6698&MevzuatTur=1&MevzuatTertip=5',
                  icon: Icons.gavel,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Kullanıcı Hakları
            _buildInfoCard(
              title: 'KVKK Kapsamındaki Haklarınız',
              icon: Icons.account_balance_wallet,
              children: [
                _buildRightItem(
                  'Bilgi Alma Hakkı',
                  'Kişisel verilerinizin işlenip işlenmediğini öğrenme hakkı',
                ),
                _buildRightItem(
                  'Erişim Hakkı',
                  'İşlenen kişisel verileriniz hakkında bilgi talep etme hakkı',
                ),
                _buildRightItem(
                  'Düzeltme Hakkı',
                  'Yanlış veya eksik verilerin düzeltilmesini isteme hakkı',
                ),
                _buildRightItem(
                  'Silme Hakkı',
                  'Kişisel verilerinizin silinmesini talep etme hakkı',
                ),
                _buildRightItem(
                  'İtiraz Hakkı',
                  'Veri işleme faaliyetlerine itiraz etme hakkı',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // İletişim Bilgileri
            _buildInfoCard(
              title: 'KVKK İletişim',
              icon: Icons.contact_support,
              children: [
                const Text(
                  'KVKK haklarınızla ilgili taleplerinizi aşağıdaki kanallar üzerinden iletebilirsiniz:',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),
                
                _buildContactItem(
                  icon: Icons.email,
                  title: 'E-posta',
                  content: 'kvkk@kanbagisc.com',
                  onTap: () => _sendEmail('kvkk@kanbagisc.com'),
                ),
                
                _buildContactItem(
                  icon: Icons.location_on,
                  title: 'Adres',
                  content: 'Bir Damla Kan Platformu\nKVKK Sorumlusu\nAnkara, Türkiye',
                ),
                
                _buildContactItem(
                  icon: Icons.access_time,
                  title: 'Yanıt Süresi',
                  content: 'Talebiniz en geç 30 gün içerisinde yanıtlanacaktır',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Uyarı Notu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Önemli Bilgilendirme',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bu uygulama, kişisel verilerinizi sadece kan bağışı süreçlerini kolaylaştırmak amacıyla toplar ve işler. '
                    'Verileriniz güvenli sunucularda saklanır ve sadece gerekli durumlarda kullanılır. '
                    'KVKK haklarınızı kullanmak için yukarıdaki iletişim bilgilerini kullanabilirsiniz.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      height: 1.4,
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

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
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
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentLink({
    required String title,
    required String subtitle,
    required String url,
    required IconData icon,
  }) {
    return Card(
      color: Colors.blue.shade50,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade700),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.blue.shade600),
        ),
        trailing: const Icon(Icons.launch, color: Colors.blue),
        onTap: () => _launchURL(url),
      ),
    );
  }

  Widget _buildRightItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Color(0xFFE53935),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFE53935), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 12,
                      color: onTap != null ? Colors.blue : Colors.grey.shade600,
                      decoration: onTap != null ? TextDecoration.underline : null,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.launch, size: 16, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('URL açılamadı: $e');
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'KVKK Talebi - Bir Damla Kan Uygulaması',
        'body': 'Merhaba,\n\nKVKK kapsamında aşağıdaki talebim bulunmaktadır:\n\n[Talebinizi buraya yazınız]\n\nTeşekkürler.',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      }
    } catch (e) {
      debugPrint('E-posta gönderilemedi: $e');
    }
  }
}