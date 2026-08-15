import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'main.dart';

class LandmarksPage extends ConsumerWidget {
  const LandmarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final landmarksAsyncValue = ref.watch(landmarksListProvider);
    final isAscending = ref.watch(sortAscendingProvider);
    final minScore = ref.watch(minScoreProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Landmarks'),
        actions: [
          IconButton(
            icon: Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              ref.read(sortAscendingProvider.notifier).state = !isAscending;
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('Min Score:'),
                Expanded(
                  child: Slider(
                    value: minScore,
                    min: -2000000,
                    max: 1000,
                    divisions: 200,
                    label: minScore == -2000000 ? 'All' : minScore.round().toString(),
                    onChanged: (value) {
                      ref.read(minScoreProvider.notifier).state = value;
                    },
                  ),
                ),
                Text(minScore == -2000000 ? 'All' : minScore.round().toString()),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(landmarkRepositoryProvider).refreshLandmarks();
                ref.invalidate(landmarksListProvider);
              },
              child: landmarksAsyncValue.when(
                data: (landmarks) {
                  if (landmarks.isEmpty) {
                    return const Center(child: Text('No landmarks found.'));
                  }
                  return ListView.builder(
                    itemCount: landmarks.length,
                    itemBuilder: (context, index) {
                      final landmark = landmarks[index];
                      return Dismissible(
                        key: ValueKey(landmark.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) async {
                          await ref.read(landmarkRepositoryProvider).softDeleteLandmark(landmark.id);
                          ref.invalidate(landmarksListProvider);
                          ref.invalidate(mapLandmarksProvider);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Landmark deleted'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () async {
                                    await ref.read(landmarkRepositoryProvider).restoreLandmark(landmark.id);
                                    ref.invalidate(landmarksListProvider);
                                    ref.invalidate(mapLandmarksProvider);
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        child: ListTile(
                          leading: SizedBox(
                            width: 50,
                            height: 50,
                            child: landmark.image.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: landmark.image,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 150,
                                  memCacheHeight: 150,
                                  placeholder: (context, url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                                )
                              : const Icon(Icons.image_not_supported, size: 40),
                          ),
                          title: Text(landmark.title),
                          subtitle: Text('Score: ${landmark.score}'),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
