import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSetupScreen extends StatefulWidget {
  const AdminSetupScreen({super.key});

  @override
  State<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createFirstAdmin() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Lütfen bir e-posta adresi girin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String email = _emailController.text.trim();
      
      // E-posta formatını kontrol et (telefon numarası ise @kanbagisc.com ekle)
      if (!email.contains('@')) {
        email = '$email@kanbagisc.com';
      }

      // Kullanıcıyı ara
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('Bu e-posta ile kayıtlı kullanıcı bulunamadı');
      }

      // Kullanıcıyı admin yap
      String userId = userQuery.docs.first.id;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'role': 'admin',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $email kullanıcısına admin yetkisi verildi!'),
            backgroundColor: Colors.green,
          ),
        );
        
        _emailController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkCurrentAdmins() async {
    try {
      QuerySnapshot adminQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      List<String> adminEmails = adminQuery.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['email'] ?? 'Bilinmeyen';
      }).toList().cast<String>();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Mevcut Admin Kullanıcıları'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (adminEmails.isEmpty)
                  const Text('❌ Hiç admin kullanıcı bulunamadı')
                else ...[
                  Text('📊 Toplam Admin: ${adminEmails.length}'),
                  const SizedBox(height: 12),
                  ...adminEmails.map((email) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.admin_panel_settings, 
                            size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(child: Text(email)),
                      ],
                    ),
                  )),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tamam'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Admin listesi alınamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Admin Yetki Yönetimi'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🛡️ Admin Yetkisi Verme',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kayıtlı bir kullanıcıya admin yetkisi vermek için e-posta adresini girin.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // E-posta TextField
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'E-posta veya Telefon Numarası',
                prefixIcon: const Icon(Icons.email, color: Color(0xFFE53935)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Admin Yap Butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createFirstAdmin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ADMİN YETKİSİ VER',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1)),
              ),
            ),

            const SizedBox(height: 16),

            // Mevcut Adminleri Görüntüle
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _checkCurrentAdmins,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE53935)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('MEVCUT ADMİNLERİ GÖRÜNTÜLE',
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1)),
              ),
            ),

            const SizedBox(height: 32),

            // Bilgi Kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Önemli Bilgiler',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Admin yetkisi verilen kullanıcılar tüm sistem işlemlerine erişebilir\n'
                    '• Admin panelinden diğer kullanıcıları yönetebilir\n'
                    '• Hastane ve sistem ayarlarını değiştirebilir\n'
                    '• Bu yetkiyi sadece güvendiğiniz kişilere verin',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}