import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';
import 'screens/qr_code_screen.dart';
import 'widgets/version_info_widget.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  User? currentUser;
  String? _selectedBloodType;
  bool _notificationsEnabled = true;
  bool _isLoading = false;
  bool _isSaving = false;

  // Kan grupları
  final List<String> _bloodTypes = [
    'Belirtmek istemiyorum',
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && !currentUser!.isAnonymous) {
        // Önce 'users' koleksiyonundan verileri çek
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          debugPrint('✅ Kullanıcı verileri yüklendi: $data');
          
          setState(() {
            _nameController.text = data['name'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _selectedBloodType = data['bloodType'];
            _notificationsEnabled = data['notificationsEnabled'] ?? true;
          });
        } else {
          debugPrint('⚠️ Kullanıcı dökümanı bulunamadı, yeni profil oluşturuluyor...');
          // Eğer kullanıcı dökümanı yoksa, temel bilgileri oluştur
          await _createInitialUserProfile();
        }
      }
    } catch (e) {
      debugPrint('❌ Profil yükleme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Profil yükleme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createInitialUserProfile() async {
    if (currentUser != null) {
      try {
        // E-posta adresinden ad çıkarma (örn: mehmet@example.com -> mehmet)
        String displayName = currentUser!.email?.split('@').first ?? 'Kullanıcı';
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .set({
          'name': displayName,
          'email': currentUser!.email,
          'phone': '',
          'bloodType': null,
          'role': 'user',
          'notificationsEnabled': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        debugPrint('✅ Yeni kullanıcı profili oluşturuldu');
        
        setState(() {
          _nameController.text = displayName;
          _phoneController.text = '';
          _selectedBloodType = null;
          _notificationsEnabled = true;
        });
      } catch (e) {
        debugPrint('❌ Kullanıcı profili oluşturma hatası: $e');
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (currentUser != null && !currentUser!.isAnonymous) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .update({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'bloodType': _selectedBloodType,
          'notificationsEnabled': _notificationsEnabled,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        debugPrint('✅ Profil güncellendi: ${_nameController.text.trim()}, ${_phoneController.text.trim()}, $_selectedBloodType');

        // Kan grubu bilgisini notification service'e kaydet
        if (_selectedBloodType != null) {
          await NotificationService.updateUserBloodType(_selectedBloodType!);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Profil başarıyla kaydedildi!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Profil kaydetme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Profil kaydetme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      await NotificationService.sendTestNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔔 Test bildirimi gönderildi!'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Test bildirimi hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // NOT: QR kod özelliği geçici olarak devre dışı bırakıldı

  @override
  Widget build(BuildContext context) {
    if (currentUser?.isAnonymous == true) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          backgroundColor: const Color(0xFFE53935),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Profil bilgilerinizi görmek için giriş yapmanız gerekiyor',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Kullanıcı Profili'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: _sendTestNotification,
            tooltip: 'Test Bildirimi Gönder',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bilgilendirme kartı
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Kan grubunuzu kaydederek acil durumlarda bildirim alabilirsiniz',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Kullanıcı bilgileri
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.account_circle, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  'Hesap Bilgileri',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('E-posta: ${currentUser?.email ?? 'Belirtilmemiş'}'),
                            Text('UID: ${currentUser?.uid.substring(0, 10)}...'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Ad Soyad
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Ad Soyad',
                          hintText: 'Adınızı ve soyadınızı girin',
                          prefixIcon: const Icon(Icons.person, color: Color(0xFFE53935)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ad soyad gerekli';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Telefon
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Telefon Numarası',
                          hintText: '05551234567',
                          prefixIcon: const Icon(Icons.phone, color: Color(0xFFE53935)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty && value.length < 10) {
                            return 'Geçerli bir telefon numarası girin';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Kan Grubu
                      DropdownButtonFormField<String>(
                        initialValue: _selectedBloodType,
                        decoration: InputDecoration(
                          labelText: 'Kan Grubu *',
                          hintText: 'Kan grubunuzu seçin',
                          prefixIcon: const Icon(Icons.bloodtype, color: Color(0xFFE53935)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                          ),
                        ),
                        items: _bloodTypes.map((String bloodType) {
                          return DropdownMenuItem<String>(
                            value: bloodType,
                            child: Text(bloodType),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null && newValue != 'Belirtmek istemiyorum') {
                            _showBloodTypeConsentDialog(newValue);
                          } else {
                            setState(() {
                              _selectedBloodType = newValue;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kan grubu seçimi gerekli';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Bildirimler
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.notifications, color: Colors.orange.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Bildirim Ayarları',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _notificationsEnabled,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _notificationsEnabled = value;
                                    });
                                  },
                                  activeThumbColor: const Color(0xFFE53935),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _notificationsEnabled
                                  ? '✅ Kan grubunuzla uyumlu taleplerde bildirim alacaksınız'
                                  : '❌ Kan talebi bildirimleri kapalı',
                              style: TextStyle(
                                color: _notificationsEnabled ? Colors.green : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Kaydet Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: 3,
                          ),
                          child: _isSaving
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Kaydediliyor...'),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save),
                                    SizedBox(width: 8),
                                    Text(
                                      'Profili Kaydet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // QR Kod Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            if (_selectedBloodType == null || _nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('QR kod oluşturmak için ad ve kan grubu bilgilerinizi tamamlayın'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            
                            // QR kod sayfasına yönlendir
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QRCodeScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE53935), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            foregroundColor: const Color(0xFFE53935),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code),
                              SizedBox(width: 8),
                              Text(
                                'QR Kodum',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      const SizedBox(height: 24),

                      // FCM Token bilgisi (debug için)
                      if (kDebugMode)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Debug Bilgileri',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              FutureBuilder<String?>(
                                future: NotificationService.getFCMToken(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      'FCM Token: ${snapshot.data!.substring(0, 20)}...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontFamily: 'monospace',
                                      ),
                                    );
                                  }
                                  return const Text('FCM Token yükleniyor...');
                                },
                              ),
                            ],
                          ),
                        ),

                        // Versiyon Bilgisi
                        const SizedBox(height: 24),
                        const Center(
                          child: VersionInfoWidget(),
                        ),
                        const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Kan grubu seçimi onay dialog'u
  Future<void> _showBloodTypeConsentDialog(String selectedBloodType) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Dialog dışına tıklayarak kapatılamaz
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.bloodtype, color: const Color(0xFFE53935), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kan Grubu Bilgisi',
                  style: TextStyle(
                    color: const Color(0xFFE53935),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                          Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'KVKK Aydınlatma Metni',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '"Acil durumlarda kullanılmak üzere kan grubumun kaydedilmesine açık rıza veriyorum. Bu bilgi, yalnızca belirtilen amaç doğrultusunda işlenecek ve talep ettiğimde tamamen silinecektir."',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Colors.blue.shade800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Seçilen kan grubu: $selectedBloodType',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bu bilgiyi onaylıyor musunuz?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'İptal',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
                // Kan grubunu eski haline döndür
                setState(() {
                  // Hiçbir değişiklik yapmadan dialog'u kapat
                });
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Onaylıyorum',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dialog'u kapat
                
                // Kan grubunu kaydet
                setState(() {
                  _selectedBloodType = selectedBloodType;
                });
                
                // Başarı mesajı göster
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('✅ Kan grubunuz $selectedBloodType olarak kaydedildi'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}