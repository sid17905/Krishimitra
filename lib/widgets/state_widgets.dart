import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_constants.dart';

/// Reusable shimmer skeletons shown while live API calls are in flight.
///
/// A shimmer skeleton communicates "content is coming" far better than a bare
/// spinner because it previews the shape of the data. Used by the weather and
/// market screens during their `LoadingState`.
class ShimmerBox extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;
  const ShimmerBox({
    super.key,
    required this.height,
    this.width,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// A vertical stack of skeleton cards approximating a typical data screen.
class ShimmerList extends StatelessWidget {
  final int items;
  const ShimmerList({super.key, this.items = 4});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(height: 120, radius: 16),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              3,
              (i) => const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: ShimmerBox(height: 70),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            items,
            (i) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ShimmerBox(height: 72),
            ),
          ),
        ],
      ),
    );
  }
}

/// A friendly, actionable error panel with a Retry button.
///
/// Distinguishes timeout / offline / generic so the copy is helpful.
class ErrorRetry extends StatelessWidget {
  final String message;
  final bool isTimeout;
  final Future<void> Function() onRetry;
  final String retryLabel;

  const ErrorRetry({
    super.key,
    required this.message,
    required this.onRetry,
    this.isTimeout = false,
    this.retryLabel = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isTimeout ? Icons.timer_off_outlined : Icons.cloud_off,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tiny pill that badges the data source as live or offline/cached.
class SourceBadge extends StatelessWidget {
  final bool isLive;
  final String liveLabel;
  final String offlineLabel;
  const SourceBadge({
    super.key,
    required this.isLive,
    this.liveLabel = 'LIVE',
    this.offlineLabel = 'OFFLINE (cached)',
  });

  @override
  Widget build(BuildContext context) {
    final color = isLive ? AppColors.primaryGreen : AppColors.warningOrange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isLive ? Icons.wifi_tethering : Icons.wifi_off,
              size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            isLive ? liveLabel : offlineLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
