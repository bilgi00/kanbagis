import 'package:flutter/material.dart';
import '../services/version_service.dart';

/// Uygulama versiyon bilgilerini gösteren widget
class VersionInfoWidget extends StatelessWidget {
  final bool showBuildNumber;
  final bool showFullVersion;
  final bool showAppName;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? borderColor;

  const VersionInfoWidget({
    super.key,
    this.showBuildNumber = true,
    this.showFullVersion = false,
    this.showAppName = true,
    this.padding,
    this.textStyle,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor ?? Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showAppName) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, 
                     color: Colors.grey.shade600, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Uygulama Bilgileri',
                  style: textStyle?.copyWith(fontWeight: FontWeight.w600) ?? 
                         TextStyle(
                           fontWeight: FontWeight.w600,
                           color: Colors.grey.shade700,
                           fontSize: 14,
                         ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          if (showFullVersion) ...[
            Text(
              'Versiyon: ${VersionService.fullVersion}',
              style: textStyle ?? TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ] else ...[
            Text(
              'Versiyon: ${VersionService.versionName}',
              style: textStyle ?? TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            if (showBuildNumber) ...[
              Text(
                'Build: ${VersionService.buildNumber}',
                style: textStyle ?? TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
          
          const SizedBox(height: 4),
          Text(
            '© 2025 Kan Başı Uygulaması',
            style: textStyle?.copyWith(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade500,
            ) ?? TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kompakt versiyon bilgisi widget'ı (sadece versiyon numarası)
class CompactVersionWidget extends StatelessWidget {
  final TextStyle? textStyle;
  final bool showLabel;

  const CompactVersionWidget({
    super.key,
    this.textStyle,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      showLabel 
        ? 'v${VersionService.versionName}' 
        : VersionService.versionName,
      style: textStyle ?? TextStyle(
        color: Colors.grey.shade600,
        fontSize: 12,
      ),
    );
  }
}

/// Debug için versiyon bilgilerini gösteren genişletilmiş widget
class DebugVersionWidget extends StatelessWidget {
  const DebugVersionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Debug - Versiyon Bilgileri',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Version Name', VersionService.versionName),
          _buildInfoRow('Build Number', VersionService.buildNumber),
          _buildInfoRow('Full Version', VersionService.fullVersion),
          _buildInfoRow('Major Version', VersionService.majorVersion.toString()),
          _buildInfoRow('Minor Version', VersionService.minorVersion.toString()),
          _buildInfoRow('Patch Version', VersionService.patchVersion.toString()),
          _buildInfoRow('Build Number Int', VersionService.buildNumberInt.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}