import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'hospital_service.dart';
import 'district_service.dart';
import 'notification_service.dart';

class AddBloodRequestScreen extends StatefulWidget {
  const AddBloodRequestScreen({super.key});

  @override
  State<AddBloodRequestScreen> createState() => _AddBloodRequestScreenState();
}

class _AddBloodRequestScreenState extends State<AddBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedBloodType;
  String? _selectedUrgency;
  String? _selectedCity;
  String? _selectedHospitalId;
  String? _selectedHospitalName;
  List<Map<String, String>> _availableHospitals = [];
  List<String> _availableDistricts = [];
  bool _isLoading = false;
  bool _isLoadingHospitals = false;
  bool _isLoadingDistricts = false;

  // Performance: Cache sistemi
  static final Map<String, List<Map<String, String>>> _hospitalCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheValidDuration = Duration(minutes: 10);

  // Kan grupları
  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-',
  ];

  // Aciliyet seviyeleri
  final List<String> _urgencyLevels = [
    'Acil', 'Orta', 'Normal',
  ];

  @override
  void initState() {
    super.initState();
    _checkUserAuthentication();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    setState(() {
      _isLoadingDistricts = true;
    });

    try {
      List<String> districts = await DistrictService.getDistrictNames();
      setState(() {
        _availableDistricts = districts;
        _isLoadingDistricts = false;
      });
    } catch (e) {
      debugPrint('❌ İlçeler yükleme hatası: $e');
      setState(() {
        _isLoadingDistricts = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ İlçeler listesi yüklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkUserAuthentication() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      // Misafir kullanıcı ise geri yönlendir
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Kan talebi oluşturmak için giriş yapmanız gerekiyor'),
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
    _patientNameController.dispose();
    _hospitalController.dispose();
    _locationController.dispose();
    _contactPhoneController.dispose();
    _contactPersonController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadHospitalsByCity(String city) async {
    setState(() {
      _isLoadingHospitals = true;
      _availableHospitals = [];
      _selectedHospitalId = null;
      _selectedHospitalName = null;
    });

    try {
      // Performance: Cache kontrol et
      final now = DateTime.now();
      final cacheKey = city.toLowerCase();
      
      if (_hospitalCache.containsKey(cacheKey) && 
          _cacheTimestamps.containsKey(cacheKey)) {
        final cacheTime = _cacheTimestamps[cacheKey]!;
        if (now.difference(cacheTime) < _cacheValidDuration) {
          // Cache'den yükle
          debugPrint('🚀 Hastaneler cache\'den yüklendi: $city');
          setState(() {
            _availableHospitals = _hospitalCache[cacheKey]!;
            _isLoadingHospitals = false;
          });
          return;
        }
      }
      
      // Cache'de yok veya expired, servisten yükle
      List<Map<String, String>> hospitals = await HospitalService.getHospitalsByRegion(city);
      
      // Cache'e kaydet
      _hospitalCache[cacheKey] = hospitals;
      _cacheTimestamps[cacheKey] = now;
      
      setState(() {
        _availableHospitals = hospitals;
        _isLoadingHospitals = false;
      });
      
      debugPrint('✅ Hastaneler servisten yüklendi ve cache\'lendi: $city');
    } catch (e) {
      debugPrint('❌ Hastane yükleme hatası: $e');
      setState(() {
        _isLoadingHospitals = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Hastane listesi yüklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveBloodRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? currentUser = FirebaseAuth.instance.currentUser;
        
        await FirebaseFirestore.instance.collection('blood_requests').add({
          'patientName': _patientNameController.text.trim(),
          'bloodType': _selectedBloodType!,
          'hospital': _selectedHospitalName ?? _hospitalController.text.trim(),
          'hospitalId': _selectedHospitalId,
          'location': _selectedCity ?? _locationController.text.trim(),
          'urgency': _selectedUrgency!,
          'contactPhone': _contactPhoneController.text.trim(),
          'contactPerson': _contactPersonController.text.trim(),
          'description': _descriptionController.text.trim(),
          'status': 'Aktif',
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': currentUser?.uid ?? 'anonymous',
          'createdByEmail': currentUser?.email ?? 'anonymous',
        });

        // 🔔 Uyumlu kan grubundaki kullanıcılara bildirim gönder
        await NotificationService.sendBloodRequestNotification(
          requiredBloodType: _selectedBloodType!,
          patientName: _patientNameController.text.trim(),
          hospitalName: _selectedHospitalName ?? _hospitalController.text.trim(),
          location: _selectedCity ?? _locationController.text.trim(),
          urgency: _selectedUrgency!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Kan talebi başarıyla oluşturuldu ve bildirimler gönderildi!'),
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
              content: Text('❌ Kan talebi oluşturma hatası: $e'),
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
    _patientNameController.clear();
    _hospitalController.clear();
    _locationController.clear();
    _contactPhoneController.clear();
    _contactPersonController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedBloodType = null;
      _selectedUrgency = null;
      _selectedCity = null;
      _selectedHospitalId = null;
      _selectedHospitalName = null;
      _availableHospitals = [];
    });
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Yeni Kan Talebi'),
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
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bloodtype, color: Colors.red.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Firebase Firestore\'a yeni kan talebi kaydı eklenecek',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Hasta Adı
                TextFormField(
                  controller: _patientNameController,
                  decoration: InputDecoration(
                    labelText: 'Hasta Adı *',
                    hintText: 'Mehmet Yılmaz',
                    prefixIcon: const Icon(Icons.person, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Hasta adı gerekli';
                    }
                    if (value.trim().length < 3) {
                      return 'Hasta adı en az 3 karakter olmalı';
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
                    hintText: 'Kan grubu seçiniz',
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
                    setState(() {
                      _selectedBloodType = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kan grubu seçimi gerekli';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Aciliyet Durumu
                DropdownButtonFormField<String>(
                  initialValue: _selectedUrgency,
                  decoration: InputDecoration(
                    labelText: 'Aciliyet Durumu *',
                    hintText: 'Aciliyet seviyesi seçiniz',
                    prefixIcon: const Icon(Icons.priority_high, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  items: _urgencyLevels.map((String urgency) {
                    return DropdownMenuItem<String>(
                      value: urgency,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getUrgencyColor(urgency),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(urgency),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedUrgency = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Aciliyet durumu seçimi gerekli';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // İlçeler yükleme durumu hakkında bilgi
                if (_isLoadingDistricts)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Kıbrıs ilçeleri veritabanından yükleniyor...',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // İlçe Seçimi
                DropdownButtonFormField<String>(
                  initialValue: _selectedCity,
                  decoration: InputDecoration(
                    labelText: 'İlçe *',
                    hintText: _isLoadingDistricts 
                        ? 'İlçeler yükleniyor...'
                        : _availableDistricts.isEmpty
                            ? 'İlçeler yüklenemedi'
                            : 'İlçe seçiniz',
                    prefixIcon: Icon(
                      _isLoadingDistricts ? Icons.hourglass_empty : Icons.location_city, 
                      color: const Color(0xFFE53935)
                    ),
                    suffixIcon: _isLoadingDistricts 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  items: _availableDistricts.map((String district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: _isLoadingDistricts || _availableDistricts.isEmpty
                      ? null
                      : (String? newValue) {
                          setState(() {
                            _selectedCity = newValue;
                            _locationController.text = newValue ?? '';
                            // İlçe değiştiğinde hastane seçimini sıfırla
                            _selectedHospitalId = null;
                            _selectedHospitalName = null;
                            _availableHospitals = [];
                          });
                          
                          // İlçe seçildiyse o ilçedeki hastaneleri yükle
                          if (newValue != null && newValue.isNotEmpty) {
                            _loadHospitalsByCity(newValue);
                          }
                        },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'İlçe seçimi gerekli';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Hastane Seçimi
                DropdownButtonFormField<String>(
                  initialValue: _selectedHospitalId,
                  decoration: InputDecoration(
                    labelText: 'Hastane *',
                    hintText: _selectedCity == null 
                        ? 'Önce ilçe seçiniz'
                        : _isLoadingHospitals 
                            ? 'Hastaneler yükleniyor...'
                            : _availableHospitals.isEmpty
                                ? 'Bu ilçede hastane bulunamadı'
                                : 'Hastane seçiniz',
                    prefixIcon: Icon(
                      _isLoadingHospitals ? Icons.hourglass_empty : Icons.local_hospital, 
                      color: const Color(0xFFE53935)
                    ),
                    suffixIcon: _isLoadingHospitals 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  items: _availableHospitals.map((hospital) {
                    return DropdownMenuItem<String>(
                      value: hospital['id'],
                      child: Text(
                        hospital['name'] ?? '',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _selectedCity == null || _isLoadingHospitals || _availableHospitals.isEmpty
                      ? null
                      : (String? hospitalId) {
                          setState(() {
                            _selectedHospitalId = hospitalId;
                            // Seçilen hastane ID'sine göre hastane adını bul
                            _selectedHospitalName = _availableHospitals
                                .firstWhere(
                                  (hospital) => hospital['id'] == hospitalId,
                                  orElse: () => {'name': ''},
                                )['name'];
                          });
                        },
                  validator: (value) {
                    if (_selectedCity != null && (value == null || value.isEmpty)) {
                      return 'Hastane seçimi gerekli';
                    }
                    return null;
                  },
                ),

                // Hastane seçimi hakkında bilgilendirme
                if (_selectedCity != null && _availableHospitals.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.green.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_availableHospitals.length} hastane $_selectedCity ilçesinde kayıtlı',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_selectedCity != null && _availableHospitals.isEmpty && !_isLoadingHospitals)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$_selectedCity ilçesinde henüz hastane kaydı yok. Yeni hastane ekleyebilirsiniz.',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // İletişim Kişisi
                TextFormField(
                  controller: _contactPersonController,
                  decoration: InputDecoration(
                    labelText: 'İletişim Kişisi *',
                    hintText: 'Dr. Ayşe Demir',
                    prefixIcon: const Icon(Icons.contact_phone, color: Color(0xFFE53935)),
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
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Telefon Numarası
                TextFormField(
                  controller: _contactPhoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9 ()-]')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Telefon Numarası *',
                    hintText: '05551234567',
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

                // Açıklama
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Açıklama *',
                    hintText: 'Ameliyat için acil kan ihtiyacı...',
                    prefixIcon: const Icon(Icons.description, color: Color(0xFFE53935)),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Açıklama gerekli';
                    }
                    if (value.trim().length < 10) {
                      return 'Açıklama en az 10 karakter olmalı';
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
                    onPressed: _isLoading ? null : _saveBloodRequest,
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
                                'Kan Talebi Oluştur',
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
                    'Firebase Firestore veritabanına yeni kan talebi kaydı eklenecek. '
                    'Oluşturulan talep gerçek zamanlı olarak tüm kullanıcılar tarafından görülebilir.',
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