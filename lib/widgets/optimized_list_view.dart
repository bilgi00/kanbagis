import 'package:flutter/material.dart';

/// Optimize edilmiş ListView widget'ı
/// Büyük listeler için performans iyileştirmeleri içerir
class OptimizedListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? separator;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool addSemanticIndexes;
  
  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separator,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.addSemanticIndexes = true,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Veri bulunamadı'),
      );
    }

    // Performance: Separated list için optimize builder
    if (separator != null) {
      return ListView.separated(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        addSemanticIndexes: addSemanticIndexes,
        itemCount: items.length,
        separatorBuilder: (context, index) => separator!,
        itemBuilder: (context, index) {
          final item = items[index];
          return _OptimizedListItem<T>(
            key: ValueKey('${item.hashCode}_$index'),
            item: item,
            index: index,
            builder: itemBuilder,
          );
        },
      );
    }

    // Performance: Normal list için optimize builder
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      addSemanticIndexes: addSemanticIndexes,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _OptimizedListItem<T>(
          key: ValueKey('${item.hashCode}_$index'),
          item: item,
          index: index,
          builder: itemBuilder,
        );
      },
    );
  }
}

/// Optimized list item widget'ı
/// Her item için ayrı key ve optimizasyonlar
class _OptimizedListItem<T> extends StatelessWidget {
  final T item;
  final int index;
  final Widget Function(BuildContext context, T item, int index) builder;

  const _OptimizedListItem({
    required Key key,
    required this.item,
    required this.index,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(context, item, index);
  }
}

/// Kan talepleri için özelleştirilmiş optimized list
class BloodRequestOptimizedList extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  final void Function(Map<String, dynamic>)? onRequestTap;
  final ScrollController? controller;

  const BloodRequestOptimizedList({
    super.key,
    required this.requests,
    this.onRequestTap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedListView<Map<String, dynamic>>(
      items: requests,
      controller: controller,
      separator: const Divider(height: 1),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, request, index) {
        return _BloodRequestCard(
          request: request,
          onTap: onRequestTap != null ? () => onRequestTap!(request) : null,
        );
      },
    );
  }
}

/// Optimize edilmiş kan talebi kartı
class _BloodRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback? onTap;

  const _BloodRequestCard({
    required this.request,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final urgency = request['urgency'] ?? 'Normal';
    final bloodType = request['bloodType'] ?? '';
    final location = request['location'] ?? '';
    final hospitalName = request['hospitalName'] ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Kan grubu badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      bloodType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Aciliyet badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getUrgencyColor(urgency),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      urgency,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Zaman bilgisi
                  if (request['timestamp'] != null)
                    Text(
                      _formatTimeAgo(request['timestamp'] as DateTime),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Hastane bilgisi
              Row(
                children: [
                  Icon(
                    Icons.local_hospital,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hospitalName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Konum bilgisi
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'acil':
        return Colors.red;
      case 'orta':
        return Colors.orange;
      case 'normal':
      default:
        return Colors.green;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }
}