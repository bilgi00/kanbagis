import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Firebase Messaging sadece gerektiğinde yükle
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'home_screen_temp.dart';
// import 'notification_service.dart';
import 'user_role_service.dart';
import 'hospital_service.dart';
import 'widgets/app_logo.dart';
import 'services/version_service.dart';
import 'services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Performance: System UI ve orientation ayarları
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  
  // Firebase'i initialize et
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Servisleri paralel olarak initialize et
  await Future.wait([
    VersionService.initialize(),
    LocalizationService.initialize(),
  ]);
  
  // 🔔 Notification services gerektiğinde etkinleştirilebilir
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // await NotificationService.initialize();
  
  runApp(const KanBasiApp());
}

class KanBasiApp extends StatelessWidget {
  const KanBasiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${'Bir Damla Kan'.tr} v${VersionService.versionName}',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFE53935),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          primary: const Color(0xFFE53935),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      locale: LocalizationService.locale,
      home: const WelcomeScreen(),
    );
  }
}

// HOŞGELDİN EKRANI
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Üst Kısım (Header)
          Container(
            height: screenHeight * 0.45,
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFFE53935)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Yeni Logo
                const AppLogo(
                  size: 120,
                  withText: false,
                ),
                const SizedBox(height: 20),
                // Bir Damla Kan yazısı
                const Text(
                  'Bir Damla Kan',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                // Alt başlık
                const Text(
                  'Hayat Kurtaran Bağış Platformu',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Alt Kısım (Butonlar)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              transform: Matrix4.translationValues(0, -30, 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Hoşgeldiniz',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Kan bağışı ile hayat kurtarmaya başlayın',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // Giriş Yap Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 3,
                          ),
                          child: const Text(
                            'GİRİŞ YAP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Kayıt Ol Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegistrationScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFE53935),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'KAYIT OL',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Misafir Devam Et Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ana ekrana yönlendiriliyor...'),
                                backgroundColor: Colors.orange,
                              ),
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'MİSAFİR DEVAM ET',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Alt bilgi metni
                      const Text(
                        'Kan bağışı ile ilgili daha fazla bilgi almak için\nuygulamamızı keşfedin.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// KAYIT OL EKRANI
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // Kan grubu ve bölge seçimi
  String? _selectedBloodType;
  String? _selectedRegion;
  String? _selectedDistrict;
  bool _canDonateBlood = true;

  // Firestore'dan çekilen veriler
  List<String> _regions = [];
  List<String> _districts = [];
  bool _isLoadingRegions = true;
  bool _isLoadingDistricts = false;

  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-',
  ];

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose(); 
    _passwordController.dispose();
    super.dispose();
  }

  // Firestore'dan şehirleri yükle
  Future<void> _loadRegions() async {
    setState(() {
      _isLoadingRegions = true;
    });

    try {
      List<String> regions = await HospitalService.getCitiesFromFirestore();
      
      // Eğer Firestore'dan veri gelmezse, boş liste döndür
      if (regions.isEmpty) {
        debugPrint('⚠️ Firestore\'dan şehir verisi gelmedi');
      }
      
      setState(() {
        _regions = regions;
        _isLoadingRegions = false;
      });
      
      debugPrint('✅ ${regions.length} şehir yüklendi: ${regions.take(5)}...');
    } catch (e) {
      debugPrint('❌ Şehirler yüklenirken hata: $e');
      setState(() {
        _regions = []; // Boş liste
        _isLoadingRegions = false;
      });
    }
  }

  // Seçilen şehre göre ilçeleri yükle
  Future<void> _loadDistricts(String city) async {
    setState(() {
      _isLoadingDistricts = true;
      _selectedDistrict = null; // İlçe seçimini sıfırla
    });

    try {
      List<String> districts = await HospitalService.getDistrictsFromFirestore(city);
      setState(() {
        _districts = districts;
        _isLoadingDistricts = false;
      });
    } catch (e) {
      debugPrint('İlçeler yüklenirken hata: $e');
      setState(() {
        _districts = []; // Boş liste
        _isLoadingDistricts = false;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBloodType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen kan grubunuzu seçiniz'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedRegion == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen bölgenizi seçiniz'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedDistrict == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen ilçenizi seçiniz'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Veri doğrulama
      final phoneText = _phoneController.text.trim();
      final passwordText = _passwordController.text.trim();
      
      if (phoneText.length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Telefon numarası en az 10 haneli olmalıdır'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (passwordText.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Şifre en az 6 karakter olmalıdır'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Firebase kayıt yap
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('� Firebase\'e kaydediliyor...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
      _saveToFirebase();
    }
  }

  void _saveToFirebase() async {
    try {
      // Firebase Authentication ile kullanıcı oluştur
      // Telefon numarasını email formatına çevir (Firebase Auth email gerektirir)
      String emailFromPhone = '${_phoneController.text.trim()}@kanbagisc.com';
      
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailFromPhone,
        password: _passwordController.text.trim(),
      );

      // Firestore'a kullanıcı bilgilerini kaydet
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': emailFromPhone,
        'bloodType': _selectedBloodType ?? '',
        'region': _selectedRegion ?? '',
        'district': _selectedDistrict ?? '',
        'canDonateBlood': _canDonateBlood,
        'role': 'user', // Varsayılan kullanıcı rolü
        'createdAt': FieldValue.serverTimestamp(),
        'uid': userCredential.user!.uid,
      });

      // Varsayılan rol ataması
      await UserRoleService.setDefaultRoleForNewUser(userCredential.user!.uid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Firebase kayıt başarılı!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Form temizle
        _nameController.clear();
        _surnameController.clear();
        _phoneController.clear();
        _passwordController.clear();
        setState(() {
          _selectedBloodType = null;
          _selectedRegion = null;
          _selectedDistrict = null;
          _canDonateBlood = true;
        });

        // Ana ekrana yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Kayıt hatası';
        if (e.toString().contains('email-already-in-use')) {
          errorMessage = 'Bu telefon numarası zaten kayıtlı!';
        } else if (e.toString().contains('weak-password')) {
          errorMessage = 'Şifre çok zayıf!';
        } else if (e.toString().contains('network-request-failed')) {
          errorMessage = 'İnternet bağlantısı hatası!';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Kayıt Ol'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '� Firebase Aktif',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'Kişisel Bilgiler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Ad TextField
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Ad',
                    prefixIcon: const Icon(Icons.person, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen adınızı giriniz';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Soyad TextField
                TextFormField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                    hintText: 'Soyad',
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen soyadınızı giriniz';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Telefon TextField
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Telefon Numarası',
                    prefixIcon: const Icon(Icons.phone, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen telefon numarası giriniz';
                    }
                    if (value.length < 10) {
                      return 'Geçerli bir telefon numarası giriniz';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  'Kan Bağışı Bilgileri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Kan Grubu Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedBloodType,
                  decoration: InputDecoration(
                    hintText: 'Kan Grubunuz',
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
                ),

                const SizedBox(height: 16),

                // Bölge Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedRegion,
                  decoration: InputDecoration(
                    hintText: _isLoadingRegions 
                        ? 'Şehirler yükleniyor...' 
                        : 'Bölgeniz/İliniz',
                    prefixIcon: _isLoadingRegions 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.location_on, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  items: _isLoadingRegions 
                      ? [] 
                      : _regions.map((String region) {
                          return DropdownMenuItem<String>(
                            value: region,
                            child: Text(region),
                          );
                        }).toList(),
                  onChanged: _isLoadingRegions 
                      ? null 
                      : (String? newValue) {
                          setState(() {
                            _selectedRegion = newValue;
                          });
                          if (newValue != null) {
                            _loadDistricts(newValue);
                          }
                        },
                ),

                const SizedBox(height: 16),

                // İlçe Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedDistrict,
                  decoration: InputDecoration(
                    hintText: _selectedRegion == null 
                        ? 'Önce bölge seçiniz' 
                        : _isLoadingDistricts
                            ? 'İlçeler yükleniyor...'
                            : 'İlçenizi seçiniz',
                    prefixIcon: _isLoadingDistricts
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.place, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  items: (_selectedRegion == null || _isLoadingDistricts)
                      ? []
                      : _districts.map((String district) {
                          return DropdownMenuItem<String>(
                            value: district,
                            child: Text(district),
                          );
                        }).toList(),
                  onChanged: (_selectedRegion == null || _isLoadingDistricts)
                      ? null 
                      : (String? newValue) {
                          setState(() {
                            _selectedDistrict = newValue;
                          });
                        },
                ),

                const SizedBox(height: 16),

                // Kan verebilir durumu
                Row(
                  children: [
                    Checkbox(
                      value: _canDonateBlood,
                      onChanged: (bool? value) {
                        setState(() {
                          _canDonateBlood = value ?? true;
                        });
                      },
                      activeColor: const Color(0xFFE53935),
                    ),
                    const Expanded(
                      child: Text(
                        'Şu anda kan verebilir durumundayım',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Şifre TextField
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Şifre',
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFFE53935)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFFE53935),
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifre giriniz';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Kayıt Ol Butonu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 3,
                    ),
                    child: const Text(
                      'KAYIT OL',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Giriş Yap linki
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,  
                  children: [
                    const Text('Zaten hesabın var mı? ',
                        style: TextStyle(fontSize: 14, color: Color(0xFF555555))),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Giriş Yap',
                          style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// GİRİŞ EKRANI
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await _loginWithFirebase();

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loginWithFirebase() async {
    try {
      String emailFromPhone = '${_emailPhoneController.text.trim()}@kanbagisc.com';
      
      // Firebase Authentication ile giriş yap
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailFromPhone,
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Firebase giriş başarılı!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Giriş hatası';
        if (e.toString().contains('user-not-found')) {
          errorMessage = 'Bu telefon numarası kayıtlı değil!';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Şifre yanlış!';
        } else if (e.toString().contains('network-request-failed')) {
          errorMessage = 'İnternet bağlantısı hatası!';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Giriş Yap'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                const Text(
                  '� Firebase Aktif',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 40),

                // E-posta/Telefon TextField
                TextFormField(
                  controller: _emailPhoneController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'E-posta veya Telefon',
                    prefixIcon: const Icon(Icons.person, color: Color(0xFFE53935)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen e-posta veya telefon giriniz';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Şifre TextField
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Şifre',
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFFE53935)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFFE53935),
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifre giriniz';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Giriş Yap Butonu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 3,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Text('GİRİŞ YAP',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1)),
                  ),
                ),

                const SizedBox(height: 20),

                // Kayıt Ol linki
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Hesabın yok mu? ',
                        style: TextStyle(fontSize: 14, color: Color(0xFF555555))),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                        );
                      },
                      child: const Text('Kayıt Ol',
                          style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Misafir Giriş
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('MİSAFİR OLARAK DEVAM ET',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1)),
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

// Hakkında Sayfası
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Hakkında'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo ve Başlık
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.bloodtype,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'KAN BAŞI',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53935),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Text(
                      'Kan Bağışı ve Talep Platformu',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Toplumsal Etki Bölümü
              _buildSectionCard(
                icon: Icons.lightbulb_outline,
                title: '💡 Toplumsal Etki',
                content: [
                  'Bu uygulama kâr amacı gütmeden geliştirilmiştir.',
                  'Amaç, kan bağışı bilincini yaymak ve acil durumlarda zamanın değerini artırmaktır.',
                  'Her bağış, bir hayata umut olabilir. 🌿',
                ],
              ),

              const SizedBox(height: 24),

              // İletişim Bölümü
              _buildSectionCard(
                icon: Icons.contact_phone,
                title: '📞 İletişim',
                content: [
                  'Web: www.suder.com.tr',
                  'E-posta: info@suder.com.tr',
                  'Facebook: Sevgi ve Umut Derneği "Su-Der',
                  'Instagram: suder_famagusta',
                  'Geliştirici: Sevgi ve Umut Derneği',
                ],
              ),

              const SizedBox(height: 24),

              // Sürüm Bilgisi Bölümü
              _buildSectionCard(
                icon: Icons.info_outline,
                title: '⚙️ Sürüm Bilgisi',
                content: [
                  'Uygulama sürümü: v1.0.0 (Beta)',
                  'Geliştirici ortamı: Flutter SDK 3.x / Dart 3.x',
                  'Platformlar: Android, Web (yakında iOS)',
                  'Yayın tarihi: 2025',
                ],
              ),

              

              

              const SizedBox(height: 40),

              // Alt Bilgi
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Hayat Kurtarmak Bu Kadar Kolay!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53935),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '© 2025 KAN BAŞI - Tüm hakları saklıdır',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
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
    required List<String> content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFE53935), size: 24),
                const SizedBox(width: 12),
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
            const SizedBox(height: 16),
            ...content.map((text) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                  height: 1.5,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}