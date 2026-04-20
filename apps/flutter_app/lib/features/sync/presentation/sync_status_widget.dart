import 'package:flutter/cupertino.dart';

import '../domain/sync_status.dart';

class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({
    super.key,
    required this.status,
  });

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final phase = status.phase;

    if (phase == SyncPhase.syncing) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CupertinoActivityIndicator(radius: 6),
          ),
          SizedBox(width: 6),
          Text(
            'Syncing...',
            style: TextStyle(fontSize: 12, color: Color(0xAA2C3A33)),
          ),
        ],
      );
    }

    if (status.pendingCount > 0) {
      final tint = phase == SyncPhase.failed
          ? const Color(0xFF8A4A2A)
          : const Color(0xFF3D5C4C);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0x22FFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x22FFFFFF)),
        ),
        child: Text(
          '${status.pendingCount} pending',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: tint,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
