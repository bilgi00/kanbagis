import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class QRGeneratorService {
  // Kan talebi için QR kod oluştur
  static String generateBloodRequestQR({
    required String requestId,
    required String hospitalName,
    required String bloodType,
    required String urgency,
    required String contactInfo,
  }) {
    final qrData = {
      'type': 'blood_request',
      'requestId': requestId,
      'hospitalName': hospitalName,
      'bloodType': bloodType,
      'urgency': urgency,
      'contactInfo': contactInfo,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return jsonEncode(qrData);
  }

  // Bağışçı profili için QR kod oluştur
  static String generateDonorQR({
    required String userId,
    required String fullName,
    required String bloodType,
    required String phone,
    required String city,
  }) {
    final qrData = {
      'type': 'donor_profile',
      'userId': userId,
      'fullName': fullName,
      'bloodType': bloodType,
      'phone': phone,
      'city': city,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return jsonEncode(qrData);
  }

  // QR kod widget'ı oluştur
  static Widget buildQRWidget({
    required String data,
    double size = 200,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: backgroundColor ?? Colors.white,
      // ignore: deprecated_member_use
      foregroundColor: foregroundColor ?? Colors.black,
      gapless: false,
      errorStateBuilder: (cxt, err) {
        return const Center(
          child: Text(
            "QR kod oluşturulamadı",
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  // QR kod gösterme dialog'u
  static void showQRDialog({
    required BuildContext context,
    required String title,
    required String data,
    String? subtitle,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subtitle != null) ...[
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            buildQRWidget(data: data, size: 250),
            const SizedBox(height: 16),
            const Text(
              'Bu QR kodu diğer kullanıcılar tarayabilir',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // QR kod verilerini parse et
  static Map<String, dynamic>? parseQRData(String qrCode) {
    try {
      final data = jsonDecode(qrCode) as Map<String, dynamic>;
      return data;
    } catch (e) {
      return null;
    }
  }

  // QR kod tipini belirle
  static String getQRType(Map<String, dynamic> qrData) {
    return qrData['type'] ?? 'unknown';
  }
}