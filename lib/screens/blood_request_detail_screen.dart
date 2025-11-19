import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodRequestDetailScreen extends StatelessWidget {
  final Map<String, dynamic> bloodRequest;

  const BloodRequestDetailScreen({
    super.key,
    required this.bloodRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Kan Talebi Detayları'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareBloodRequest(context),
            tooltip: 'Paylaş',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aciliyet ve Kan Grubu Kartı
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getUrgencyColor(bloodRequest['urgency']),
                      _getUrgencyColor(bloodRequest['urgency']).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Kan Grubu
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          bloodRequest['bloodType'] ?? 'A+',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getUrgencyColor(bloodRequest['urgency']),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Aciliyet
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${bloodRequest['urgency']} Durum',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Hasta Bilgileri
            _buildInfoCard(
              title: 'Hasta Bilgileri',
              icon: Icons.person,
              children: [
                _buildInfoRow('Hasta Adı', bloodRequest['patientName'] ?? 'Belirtilmemiş'),
                _buildInfoRow('Kan Grubu', bloodRequest['bloodType'] ?? 'A+'),
                _buildInfoRow('Açıklama', bloodRequest['description'] ?? 'Açıklama bulunmuyor'),
              ],
            ),

            const SizedBox(height: 16),

            // Hastane Bilgileri
            _buildInfoCard(
              title: 'Hastane Bilgileri',
              icon: Icons.local_hospital,
              children: [
                _buildInfoRow('Hastane', bloodRequest['hospitalName'] ?? 'Belirtilmemiş'),
                _buildInfoRow('Konum', bloodRequest['location'] ?? 'Konum belirtilmemiş'),
              ],
            ),

            const SizedBox(height: 16),

            // İletişim Bilgileri
            _buildInfoCard(
              title: 'İletişim Bilgileri',
              icon: Icons.contact_phone,
              children: [
                _buildInfoRow('İletişim Kişisi', bloodRequest['contactPerson'] ?? 'Belirtilmemiş'),
                _buildContactRow(
                  'Telefon',
                  bloodRequest['contactPhone'] ?? '055*******',
                  onTap: () => _makePhoneCall(bloodRequest['contactPhone']),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Zaman Bilgisi
            _buildInfoCard(
              title: 'Talep Bilgileri',
              icon: Icons.schedule,
              children: [
                _buildInfoRow('Talep Zamanı', _formatDateTime(bloodRequest['timestamp'])),
                _buildInfoRow('Durum', 'Aktif'),
                _buildInfoRow('Aciliyet', bloodRequest['urgency'] ?? 'Normal'),
              ],
            ),

            const SizedBox(height: 24),

            // Aksiyon Butonları
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(bloodRequest['contactPhone']),
                    icon: const Icon(Icons.call),
                    label: const Text('Ara'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendSMS(bloodRequest['contactPhone']),
                    icon: const Icon(Icons.message),
                    label: const Text('Mesaj'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Konum Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openMaps(bloodRequest['location']),
                icon: const Icon(Icons.location_on),
                label: const Text('Haritada Göster'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Uyarı Notu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Önemli Bilgi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kan bağışı yapmadan önce hastane ile iletişime geçerek mevcut durumu teyit edin. '
                    'Kan bağışı için gerekli sağlık koşullarını sağladığınızdan emin olun.',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
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
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(String label, String value, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: onTap != null ? Colors.blue : Colors.black,
                        decoration: onTap != null ? TextDecoration.underline : null,
                      ),
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.launch, size: 16, color: Colors.blue),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(String? urgency) {
    switch (urgency?.toLowerCase()) {
      case 'acil':
        return Colors.red;
      case 'orta':
        return Colors.orange;
      case 'normal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Belirtilmemiş';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty || phoneNumber == '055*******') {
      return;
    }
    
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      debugPrint('Telefon araması başlatılamadı: $e');
    }
  }

  Future<void> _sendSMS(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty || phoneNumber == '055*******') {
      return;
    }
    
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {
        'body': 'Merhaba, ${bloodRequest['bloodType']} kan grubu bağışında bulunmak istiyorum. ${bloodRequest['hospitalName']} hastanesi için...'
      },
    );
    
    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    } catch (e) {
      debugPrint('SMS gönderilemedi: $e');
    }
  }

  Future<void> _openMaps(String? location) async {
    if (location == null || location.isEmpty) {
      return;
    }
    
    // Hastane adı + konum bilgisini birleştir
    String searchQuery = location;
    if (bloodRequest['hospitalName'] != null) {
      searchQuery = '${bloodRequest['hospitalName']}, $location';
    }
    
    final Uri mapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(searchQuery)}');
    
    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Haritalar açılamadı: $e');
    }
  }

  void _shareBloodRequest(BuildContext context) {
    final shareText = '''
🩸 ACİL KAN TALEBİ 🩸

Kan Grubu: ${bloodRequest['bloodType']}
Hasta: ${bloodRequest['patientName']}
Hastane: ${bloodRequest['hospitalName']}
Konum: ${bloodRequest['location']}
Aciliyet: ${bloodRequest['urgency']}
İletişim: ${bloodRequest['contactPhone']}

${bloodRequest['description']}

Bir Damla Kan Uygulaması ile paylaşıldı.
    ''';

    try {
      Clipboard.setData(ClipboardData(text: shareText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Kan talebi bilgileri panoya kopyalandı'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Paylaşım sırasında hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}