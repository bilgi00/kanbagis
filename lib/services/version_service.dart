import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Uygulama versiyon bilgilerini yöneten servis
/// pubspec.yaml'daki version bilgisini tek kaynak olarak kullanır
class VersionService {
  static String? _versionName;
  static String? _buildNumber;
  static String? _fullVersion;
  static bool _isInitialized = false;

  /// pubspec.yaml'dan versiyon bilgilerini yükler
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // pubspec.yaml dosyasını oku
      final String pubspecContent = await rootBundle.loadString('pubspec.yaml');
      
      // Version satırını bul (format: version: 1.0.3+3)
      final RegExp versionRegex = RegExp(r'^version:\s*(.+)\+(.+)$', multiLine: true);
      final Match? match = versionRegex.firstMatch(pubspecContent);

      if (match != null) {
        _versionName = match.group(1)?.trim(); // 1.0.3
        _buildNumber = match.group(2)?.trim(); // 3
        _fullVersion = '$_versionName+$_buildNumber'; // 1.0.3+3
      } else {
        // Fallback: Version format version: 1.0.3 (without build number)
        final RegExp simpleVersionRegex = RegExp(r'^version:\s*(.+)$', multiLine: true);
        final Match? simpleMatch = simpleVersionRegex.firstMatch(pubspecContent);
        
        if (simpleMatch != null) {
          final String fullVersionStr = simpleMatch.group(1)?.trim() ?? '1.0.0';
          if (fullVersionStr.contains('+')) {
            final parts = fullVersionStr.split('+');
            _versionName = parts[0];
            _buildNumber = parts[1];
          } else {
            _versionName = fullVersionStr;
            _buildNumber = '1';
          }
          _fullVersion = '$_versionName+$_buildNumber';
        }
      }

      // Değerler yüklenmediyse default değerler
      _versionName ??= '1.0.0';
      _buildNumber ??= '1';
      _fullVersion ??= '$_versionName+$_buildNumber';

      _isInitialized = true;
      
      debugPrint('📱 VersionService initialized:');
      debugPrint('   Version Name: $_versionName');
      debugPrint('   Build Number: $_buildNumber');
      debugPrint('   Full Version: $_fullVersion');
      
    } catch (e) {
      debugPrint('❌ VersionService initialization error: $e');
      // Fallback values
      _versionName = '1.0.0';
      _buildNumber = '1';
      _fullVersion = '1.0.0+1';
      _isInitialized = true;
    }
  }

  /// Kullanıcıya gösterilen versiyon numarası (örn: "1.0.3")
  static String get versionName {
    if (!_isInitialized) {
      throw StateError('VersionService not initialized. Call VersionService.initialize() first.');
    }
    return _versionName ?? '1.0.0';
  }

  /// Build numarası (örn: "3")
  static String get buildNumber {
    if (!_isInitialized) {
      throw StateError('VersionService not initialized. Call VersionService.initialize() first.');
    }
    return _buildNumber ?? '1';
  }

  /// Tam versiyon bilgisi (örn: "1.0.3+3")
  static String get fullVersion {
    if (!_isInitialized) {
      throw StateError('VersionService not initialized. Call VersionService.initialize() first.');
    }
    return _fullVersion ?? '1.0.0+1';
  }

  /// Build numarasını integer olarak döndürür
  static int get buildNumberInt {
    return int.tryParse(buildNumber) ?? 1;
  }

  /// Major versiyon numarasını döndürür (örn: 1.0.3 → 1)
  static int get majorVersion {
    final parts = versionName.split('.');
    return int.tryParse(parts.isNotEmpty ? parts[0] : '1') ?? 1;
  }

  /// Minor versiyon numarasını döndürür (örn: 1.0.3 → 0)
  static int get minorVersion {
    final parts = versionName.split('.');
    return int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
  }

  /// Patch versiyon numarasını döndürür (örn: 1.0.3 → 3)
  static int get patchVersion {
    final parts = versionName.split('.');
    return int.tryParse(parts.length > 2 ? parts[2] : '0') ?? 0;
  }

  /// Versiyon bilgilerini Map olarak döndürür
  static Map<String, dynamic> get versionInfo {
    return {
      'versionName': versionName,
      'buildNumber': buildNumber,
      'fullVersion': fullVersion,
      'buildNumberInt': buildNumberInt,
      'majorVersion': majorVersion,
      'minorVersion': minorVersion,
      'patchVersion': patchVersion,
      'isInitialized': _isInitialized,
    };
  }

  /// Debug için versiyon bilgilerini yazdırır
  static void printVersionInfo() {
    debugPrint('📱 =========================');
    debugPrint('📱 VERSION INFO');
    debugPrint('📱 =========================');
    debugPrint('📱 Version Name: $versionName');
    debugPrint('📱 Build Number: $buildNumber');
    debugPrint('📱 Full Version: $fullVersion');
    debugPrint('📱 Major: $majorVersion');
    debugPrint('📱 Minor: $minorVersion');
    debugPrint('📱 Patch: $patchVersion');
    debugPrint('📱 Build Int: $buildNumberInt');
    debugPrint('📱 Initialized: $_isInitialized');
    debugPrint('📱 =========================');
  }

  /// Versiyon servisini sıfırlar (test amaçlı)
  static void reset() {
    _versionName = null;
    _buildNumber = null;
    _fullVersion = null;
    _isInitialized = false;
  }
}