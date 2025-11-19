import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'hospital_service.dart';

class AddHospitalScreen extends StatefulWidget {
  const AddHospitalScreen({super.key});

  @override
  State<AddHospitalScreen> createState() => _AddHospitalScreenState();
}

class _AddHospitalScreenState extends State<AddHospitalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalNameController = TextEditingController();
  final _regionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  
  bool _isLoading = false;

  // Türkiye'nin 81 ili
  final List<String> _turkishCities = [
    'Adana', 'Adıyaman', 'Afyonkarahisar', 'Ağrı', 'Amasya', 'Ankara',
    'Antalya', 'Artvin', 'Aydın', 'Balıkesir', 'Bilecik', 'Bingöl',
    'Bitlis', 'Bolu', 'Burdur', 'Bursa', 'Çanakkale', 'Çankırı',
    'Çorum', 'Denizli', 'Diyarbakır', 'Edirne', 'Elazığ', 'Erzincan',
    'Erzurum', 'Eskişehir', 'Gaziantep', 'Giresun', 'Gümüşhane',
    'Hakkâri', 'Hatay', 'Isparta', 'Mersin', 'İstanbul', 'İzmir',
    'Kars', 'Kastamonu', 'Kayseri', 'Kırklareli', 'Kırşehir',
    'Kocaeli', 'Konya', 'Kütahya', 'Malatya', 'Manisa', 'Kahramanmaraş',
    'Mardin', 'Muğla', 'Muş', 'Nevşehir', 'Niğde', 'Ordu', 'Rize',
    'Sakarya', 'Samsun', 'Siirt', 'Sinop', 'Sivas', 'Tekirdağ',
    'Tokat', 'Trabzon', 'Tunceli', 'Şanlıurfa', 'Uşak', 'Van',
    'Yozgat', 'Zonguldak', 'Aksaray', 'Bayburt', 'Karaman',
    'Kırıkkale', 'Batman', 'Şırnak', 'Bartın', 'Ardahan', 'Iğdır',
    'Yalova', 'Karabük', 'Kilis', 'Osmaniye', 'Düzce',
  ];

  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _checkUserAuthentication();
  }

  Future<void> _checkUserAuthentication() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      // Misafir kullanıcı ise geri yönlendir
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Hastane eklemek için giriş yapmanız gerekiyor'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _hospitalNameController.dispose();
    _regionController.dispose();
    _phoneController.dispose();
    _contactPersonController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _saveHospital() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await HospitalService.addHospital(
          hospitalName: _hospitalNameController.text.trim(),
          region: _selectedCity ?? _regionController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          contactPerson: _contactPersonController.text.trim(),
          address: _addressController.text.trim(),
          email: _emailController.text.trim(),
          website: _websiteController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Hastane başarıyla eklendi!'),
              backgroundColor: Colors.green,
            ),
          );

          // Formu temizle
          _clearForm();
          
          // Geri dön
          Navigator.pop(context, true); // true = yenilensin
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Hastane ekleme hatası: $e'),
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
  }

  void _clearForm() {
    _hospitalNameController.clear();
    _regionController.clear();
    _phoneController.clear();
    _contactPersonController.clear();
    _addressController.clear();
    _emailController.clear();
    _websiteController.clear();
    setState(() {
      _selectedCity = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Yeni Hastane Ekle'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearForm,
            tooltip: 'Formu Temizle',
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                      Icon(Icons.info, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Firebase Firestore\'a yeni hastane kaydı eklenecek',
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

                // Hastane Adı
                TextFormField(
                  controller: _hospitalNameController,
                  decoration: InputDecoration(
                    labelText: 'Hastane Adı *',
                    hintText: 'Ankara Şehir Hastanesi',
                    prefixIcon: const Icon(Icons.local_hospital, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Hastane adı gerekli';
                    }
                    if (value.trim().length < 3) {
                      return 'Hastane adı en az 3 karakter olmalı';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Şehir Seçimi
                DropdownButtonFormField<String>(
                  initialValue: _selectedCity,
                  decoration: InputDecoration(
                    labelText: 'Şehir *',
                    hintText: 'Şehir seçiniz',
                    prefixIcon: const Icon(Icons.location_city, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  items: _turkishCities.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCity = newValue;
                      _regionController.text = newValue ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şehir seçimi gerekli';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // İletişim Kişisi
                TextFormField(
                  controller: _contactPersonController,
                  decoration: InputDecoration(
                    labelText: 'İletişim Kişisi *',
                    hintText: 'Dr. Mehmet Yılmaz',
                    prefixIcon: const Icon(Icons.person, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'İletişim kişisi gerekli';
                    }
                    if (value.trim().length < 3) {
                      return 'İletişim kişisi en az 3 karakter olmalı';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Telefon Numarası
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9 ()-]')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Telefon Numarası *',
                    hintText: '0312 552 60 00',
                    prefixIcon: const Icon(Icons.phone, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Telefon numarası gerekli';
                    }
                    if (value.trim().length < 10) {
                      return 'Geçerli bir telefon numarası girin';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // E-posta
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-posta',
                    hintText: 'info@hastane.com',
                    prefixIcon: const Icon(Icons.email, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                        return 'Geçerli bir e-posta adresi girin';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Web Sitesi
                TextFormField(
                  controller: _websiteController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: 'Web Sitesi',
                    hintText: 'www.hastane.com',
                    prefixIcon: const Icon(Icons.language, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Adres
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Adres *',
                    hintText: 'Örnek: Bahçelievler Mah. Necatibey Cad. No:15, Çankaya, Ankara',
                    prefixIcon: const Icon(Icons.location_on, color: Color(0xFFE53935)),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                    helperText: 'Format: Sokak/Mahalle, İlçe, İl',
                    helperStyle: TextStyle(color: Colors.grey.shade600),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Adres bilgisi gerekli';
                    }
                    if (value.trim().length < 10) {
                      return 'Lütfen detaylı adres bilgisi girin (en az 10 karakter)';
                    }
                    // Virgül kontrolü
                    if (!value.contains(',')) {
                      return 'Lütfen "Sokak/Mahalle, İlçe, İl" formatında girin';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Kaydet Butonu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveHospital,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 3,
                    ),
                    child: _isLoading
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
                              Text('Firebase\'e Kaydediliyor...'),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload),
                              SizedBox(width: 8),
                              Text(
                                'Firebase\'e Kaydet',
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

                // İptal Butonu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE53935), width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: const Text(
                      'İptal',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Bilgilendirme metni
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '* Zorunlu alanlar\n\n'
                    'Firebase Firestore veritabanına yeni hastane kaydı eklenecek. '
                    'Eklenen veriler gerçek zamanlı olarak tüm kullanıcılar tarafından görülebilir.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}