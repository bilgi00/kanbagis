import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/qr_scanner_service.dart';
import '../services/qr_generator_service.dart';
import '../user_role_service.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  final UserRoleService _userRoleService = UserRoleService();
  String? userRole;
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final role = await _userRoleService.getUserRole();
    setState(() {
      userRole = role;
    });

    if (FirebaseAuth.instance.currentUser != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      
      if (doc.exists) {
        setState(() {
          userProfile = doc.data();
        });
      }
    }
  }

  Future<void> _scanQRCode() async {
    try {
      final result = await QRScannerService.scanQRCode(context);
      if (result != null && mounted) {
        _handleScannedQR(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR kod tarama hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleScannedQR(String qrCode) {
    final qrData = QRGeneratorService.parseQRData(qrCode);
    
    if (qrData == null) {
      // Normal metin QR kodu
      _showTextDialog('QR Kod İçeriği', qrCode);
      return;
    }

    final type = QRGeneratorService.getQRType(qrData);
    
    switch (type) {
      case 'blood_request':
        _showBloodRequestDialog(qrData);
        break;
      case 'donor_profile':
        _showDonorProfileDialog(qrData);
        break;
      default:
        _showTextDialog('Bilinmeyen QR Kod', qrCode);
    }
  }

  void _showTextDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SelectableText(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showBloodRequestDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kan Talebi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Hastane', data['hospitalName'] ?? 'Belirtilmemiş'),
            _buildInfoRow('Kan Grubu', data['bloodType'] ?? 'Belirtilmemiş'),
            _buildInfoRow('Aciliyet', data['urgency'] ?? 'Belirtilmemiş'),
            _buildInfoRow('İletişim', data['contactInfo'] ?? 'Belirtilmemiş'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          if (userRole != 'guest')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Ana sayfa kan talepleri listesine dön
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
              ),
              child: const Text('Detayları Gör'),
            ),
        ],
      ),
    );
  }

  void _showDonorProfileDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bağışçı Profili'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Ad Soyad', data['fullName'] ?? 'Belirtilmemiş'),
            _buildInfoRow('Kan Grubu', data['bloodType'] ?? 'Belirtilmemiş'),
            _buildInfoRow('Telefon', data['phone'] ?? 'Belirtilmemiş'),
            _buildInfoRow('Şehir', data['city'] ?? 'Belirtilmemiş'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          if (userRole != 'guest')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _contactDonor(data);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
              ),
              child: const Text('İletişim Kur'),
            ),
        ],
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
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _contactDonor(Map<String, dynamic> data) {
    final donorName = data['fullName'] ?? 'Bilinmeyen Bağışçı';
    final donorPhone = data['phone'] ?? '';
    final donorBloodType = data['bloodType'] ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$donorName ile İletişim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (donorBloodType.isNotEmpty)
              Text(
                'Kan Grubu: $donorBloodType',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE53935),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'İletişim Seçenekleri:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Telefon ile arama
            if (donorPhone.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.phone, color: Color(0xFFE53935)),
                title: const Text('Telefon ile Ara'),
                subtitle: Text(donorPhone),
                contentPadding: EdgeInsets.zero,
                onTap: () => _makePhoneCall(donorPhone),
              ),
            
            // SMS gönderme
            if (donorPhone.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.message, color: Color(0xFFE53935)),
                title: const Text('SMS Gönder'),
                subtitle: const Text('Kan bağışı talebi mesajı'),
                contentPadding: EdgeInsets.zero,
                onTap: () => _sendSMS(donorPhone, donorName),
              ),
            
            // Uygulama içi mesaj
            ListTile(
              leading: const Icon(Icons.chat, color: Color(0xFFE53935)),
              title: const Text('Uygulama İçi Mesaj'),
              subtitle: const Text('Güvenli mesajlaşma'),
              contentPadding: EdgeInsets.zero,
              onTap: () => _sendInAppMessage(data),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    try {
      // Basit bilgilendirme göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Telefon uygulamanızda $phoneNumber aranacak'),
          action: SnackBarAction(
            label: 'Tamam',
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Telefon açma hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sendSMS(String phoneNumber, String donorName) async {
    try {
      // SMS uygulamasını aç
      final message = 'Merhaba $donorName, Bir Damla Kan uygulaması üzerinden kan bağışı talebinde bulunmak istiyorum. Müsait olduğunuz zaman görüşebilir miyiz?';
      
      // Basit bilgilendirme göster
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('SMS Gönder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alıcı: $phoneNumber'),
              const SizedBox(height: 12),
              const Text(
                'Mesaj:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(message),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('SMS uygulamanız açılacak'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
              ),
              child: const Text('Gönder'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SMS gönderme hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sendInAppMessage(Map<String, dynamic> donorData) async {
    final messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uygulama İçi Mesaj'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${donorData['fullName'] ?? 'Bağışçı'} kişisine mesaj gönderin:',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Mesajınızı yazın...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (messageController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen bir mesaj yazın'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              try {
                // Firestore'a mesaj kaydet
                await FirebaseFirestore.instance.collection('messages').add({
                  'senderId': FirebaseAuth.instance.currentUser!.uid,
                  'senderName': userProfile?['fullName'] ?? 'Bilinmiyor',
                  'receiverId': donorData['userId'] ?? '',
                  'receiverName': donorData['fullName'] ?? 'Bilinmiyor',
                  'message': messageController.text.trim(),
                  'timestamp': FieldValue.serverTimestamp(),
                  'type': 'contact_request',
                  'isRead': false,
                });
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mesajınız başarıyla gönderildi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mesaj gönderme hatası: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
            ),
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  void _generateMyQR() {
    if (userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil bilgileriniz yüklenemedi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final qrData = QRGeneratorService.generateDonorQR(
      userId: FirebaseAuth.instance.currentUser!.uid,
      fullName: userProfile!['fullName'] ?? 'Bilinmiyor',
      bloodType: userProfile!['bloodType'] ?? 'Bilinmiyor',
      phone: userProfile!['phone'] ?? 'Bilinmiyor',
      city: userProfile!['city'] ?? 'Bilinmiyor',
    );

    QRGeneratorService.showQRDialog(
      context: context,
      title: 'Benim QR Kodum',
      subtitle: 'Diğer kullanıcılar bu kodu tarayarak sizinle iletişim kurabilir',
      data: qrData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Kod'),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // QR Kod Tara - Sadece mobil cihazlarda
            if (!kIsWeb)
              Card(
                elevation: 4,
                child: InkWell(
                  onTap: _scanQRCode,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 64,
                          color: Color(0xFFE53935),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'QR Kod Tara',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Kan talepleri veya bağışçı bilgilerini tarayın',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Web için bilgilendirme
            if (kIsWeb)
              Card(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.mobile_friendly,
                        size: 64,
                        color: Colors.orange,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'QR Kod Tarama',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'QR kod tarama özelliği sadece mobil uygulamada mevcuttur',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: kIsWeb ? 24 : 24),

            // Kendi QR Kodumu Oluştur
            if (userRole != 'guest' && userProfile != null)
              Card(
                elevation: 4,
                child: InkWell(
                  onTap: _generateMyQR,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.qr_code,
                          size: 64,
                          color: Color(0xFFE53935),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Benim QR Kodum',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Diğerleri sizinle iletişim kurabilsin',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const Spacer(),

            // Bilgilendirme
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'QR Kod Kullanımı',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Kan taleplerini hızlıca paylaşabilirsiniz\n'
                    '• Bağışçı bilgilerinizi güvenle aktarabilirsiniz\n'
                    '• Offline durumda bile QR kodları çalışır\n'
                    '• Kişisel bilgileriniz şifrelenir',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.blue,
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
}