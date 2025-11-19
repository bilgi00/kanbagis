import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class QRScannerService {
  static Future<String?> scanQRCode(BuildContext context) async {
    // Web platformunda QR tarama devre dışı
    if (kIsWeb) {
      _showWebNotSupportedDialog(context);
      return null;
    }

    // Mobil platformlarda da şimdilik devre dışı 
    // (qr_code_scanner paketi web uyumluluğu için kaldırıldı)
    _showMobileNotImplementedDialog(context);
    return null;
  }

  static void _showWebNotSupportedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Kod Tarama'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'QR kod tarama özelliği web platformunda desteklenmemektedir.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Lütfen mobil uygulamayı kullanın.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
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

  static void _showMobileNotImplementedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Kod Tarama'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction,
              size: 48,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Text(
              'QR kod tarama özelliği henüz geliştirme aşamasındadır.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Yakında mobil cihazlarda kullanılabilir olacak.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
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
}