import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'main.dart';

class ActivityPage extends ConsumerWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(visitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Activity History')),
      body: visitsAsync.when(
        data: (visits) {
          if (visits.isEmpty) {
            return const Center(child: Text('No visits yet. Go to Map or Landmarks to start a visit.'));
          }
          return ListView.builder(
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visit = visits[index];
              final date = DateTime.fromMillisecondsSinceEpoch(visit['created_at']);
              final dateStr = DateFormat.yMMMd().add_jm().format(date);
              
              String trailingText = visit['status'];
              if (visit['status'] == 'DONE' && visit['distance'] != null) {
                 trailingText = '${(visit['distance'] as num).toStringAsFixed(2)} m'; 
              }

              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(visit['landmark_title']),
                subtitle: Text(dateStr),
                trailing: Text(
                  trailingText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: visit['status'] == 'DONE' ? Colors.green 
                         : visit['status'] == 'PENDING' ? Colors.orange 
                         : visit['status'] == 'QUEUED' ? Colors.blue
                         : Colors.red,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
