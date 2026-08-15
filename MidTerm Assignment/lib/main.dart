import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:workmanager/workmanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'map_page.dart';
import 'landmarks_page.dart';
import 'activity_page.dart';
import 'add_landmark_page.dart';

// ==========================================
// 1. API CONFIGURATION & DTOs
// ==========================================

class ApiConfig {
  static const String baseUrl = 'https://labs.anontech.info/cse489/exm3/api.php';
  static const String apiKey = '24241189';
}

class JobResponseDto {
  final int jobId;
  final String status;

  JobResponseDto({
    required this.jobId,
    required this.status,
  });

  factory JobResponseDto.fromJson(Map<String, dynamic> json) {
    return JobResponseDto(
      jobId: json['job_id'] is int ? json['job_id'] : int.parse(json['job_id'].toString()),
      status: json['status'] ?? '',
    );
  }
}

class JobStatusDto {
  final int jobId;
  final String status;
  final double? distance;

  JobStatusDto({
    required this.jobId,
    required this.status,
    this.distance,
  });

  factory JobStatusDto.fromJson(Map<String, dynamic> json) {
    return JobStatusDto(
      jobId: json['job_id'] is int ? json['job_id'] : int.parse(json['job_id'].toString()),
      status: json['status'] ?? '',
      distance: json['distance'] != null ? (json['distance']).toDouble() : null,
    );
  }
}

class LandmarkDto {
  final int id;
  final String title;
  final double lat;
  final double lon;
  final String _imagePath;
  final double score;
  final int visitCount;
  final double avgDistance;

  String get image {
    if (_imagePath.isEmpty) return '';
    String sanitized = _imagePath.replaceAll('\\', '/');
    if (!sanitized.startsWith('http')) {
      return 'https://labs.anontech.info/cse489/exm3/$sanitized';
    }
    return sanitized;
  }

  LandmarkDto({
    required this.id,
    required this.title,
    required this.lat,
    required this.lon,
    required String image,
    required this.score,
    required this.visitCount,
    required this.avgDistance,
  }) : _imagePath = image;

  factory LandmarkDto.fromJson(Map<String, dynamic> json) {
    return LandmarkDto(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      lon: (json['lon'] ?? 0).toDouble(),
      image: json['image'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      visitCount: (json['visit_count'] as num?)?.toInt() ?? 0,
      avgDistance: (json['avg_distance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ==========================================
// 2. REMOTE API CLIENT
// ==========================================

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl)) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.queryParameters['key'] = ApiConfig.apiKey;
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 403) {
          final errorMsg = e.response?.data is Map
              ? (e.response?.data['error'] ?? 'invalid_or_expired_key')
              : 'invalid_or_expired_key';
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: 'Authentication Error (403): $errorMsg. Please check your student key.',
            ),
          );
        }
        return handler.next(e);
      },
    ));
  }

  Future<List<LandmarkDto>> getLandmarks() async {
    final response = await _dio.get('', queryParameters: {'action': 'get_landmarks'});
    if (response.data is List) {
      return (response.data as List).map((e) => LandmarkDto.fromJson(e)).toList();
    }
    return [];
  }

  Future<JobResponseDto> visitLandmark(int landmarkId, double userLat, double userLon) async {
    final response = await _dio.post(
      '',
      queryParameters: {'action': 'visit_landmark'},
      data: {
        'landmark_id': landmarkId,
        'user_lat': userLat,
        'user_lon': userLon,
      },
      options: Options(contentType: Headers.jsonContentType),
    );
    return JobResponseDto.fromJson(response.data);
  }

  Future<JobStatusDto> getJobStatus(int jobId) async {
    final response = await _dio.get(
      '',
      queryParameters: {'action': 'get_job_status', 'job_id': jobId},
    );
    return JobStatusDto.fromJson(response.data);
  }

  Future<void> createLandmark(String title, double lat, double lon, File imageFile) async {
    final formData = FormData.fromMap({
      'title': title,
      'lat': lat,
      'lon': lon,
      'image': await MultipartFile.fromFile(imageFile.path),
    });

    await _dio.post(
      '',
      queryParameters: {'action': 'create_landmark'},
      data: formData,
    );
  }

  Future<void> deleteLandmark(int id) async {
    await _dio.post(
      '',
      queryParameters: {'action': 'delete_landmark'},
      data: {'id': id},
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<void> restoreLandmark(int id) async {
    await _dio.post(
      '',
      queryParameters: {'action': 'restore_landmark'},
      data: {'id': id},
      options: Options(contentType: Headers.jsonContentType),
    );
  }
}

// ==========================================
// 3. LOCAL DATABASE & DAOs
// ==========================================

class DatabaseHelper {
  static const _databaseName = "SmartLandmarks.db";
  static const _databaseVersion = 2;

  static const tableLandmarks = 'landmarks';
  static const tableVisits = 'visits';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableLandmarks (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        lat REAL NOT NULL,
        lon REAL NOT NULL,
        image TEXT NOT NULL,
        score REAL NOT NULL,
        visit_count INTEGER NOT NULL,
        avg_distance REAL NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
      ''');

    await db.execute('''
      CREATE TABLE $tableVisits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        landmark_id INTEGER NOT NULL,
        landmark_title TEXT NOT NULL,
        job_id INTEGER,
        user_lat REAL NOT NULL,
        user_lon REAL NOT NULL,
        distance REAL,
        status TEXT NOT NULL, 
        created_at INTEGER NOT NULL
      )
      ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $tableLandmarks RENAME TO _landmarks_old');
      await db.execute('''
        CREATE TABLE $tableLandmarks (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          lat REAL NOT NULL,
          lon REAL NOT NULL,
          image TEXT NOT NULL,
          score REAL NOT NULL,
          visit_count INTEGER NOT NULL,
          avg_distance REAL NOT NULL,
          is_deleted INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('INSERT INTO $tableLandmarks SELECT * FROM _landmarks_old');
      await db.execute('DROP TABLE _landmarks_old');
    }
  }
}

class LandmarkDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> upsertLandmarks(List<Map<String, dynamic>> landmarks) async {
    final db = await _dbHelper.database;
    Batch batch = db.batch();
    for (var landmark in landmarks) {
      batch.insert(
        DatabaseHelper.tableLandmarks,
        landmark,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);

    final updateBatch = db.batch();
    for (var landmark in landmarks) {
      updateBatch.update(
        DatabaseHelper.tableLandmarks,
        {
          'title': landmark['title'],
          'lat': landmark['lat'],
          'lon': landmark['lon'],
          'image': landmark['image'],
          'score': landmark['score'],
          'visit_count': landmark['visit_count'],
          'avg_distance': landmark['avg_distance'],
        },
        where: 'id = ?',
        whereArgs: [landmark['id']],
      );
    }
    await updateBatch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getActiveLandmarks({
    String sortBy = 'score',
    bool ascending = true,
    double minScore = -double.maxFinite,
  }) async {
    final db = await _dbHelper.database;
    final String orderBy = '$sortBy ${ascending ? 'ASC' : 'DESC'}';
    return await db.query(
      DatabaseHelper.tableLandmarks,
      where: 'is_deleted = 0 AND score >= ?',
      whereArgs: [minScore],
      orderBy: orderBy,
    );
  }

  Future<void> softDeleteLandmark(int id) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.tableLandmarks,
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> restoreLandmark(int id) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.tableLandmarks,
      {'is_deleted': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class VisitDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insertVisit(Map<String, dynamic> visit) async {
    final db = await _dbHelper.database;
    return await db.insert(DatabaseHelper.tableVisits, visit);
  }

  Future<List<Map<String, dynamic>>> getAllVisits() async {
    final db = await _dbHelper.database;
    return await db.query(
      DatabaseHelper.tableVisits,
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getVisitsByStatus(String status) async {
    final db = await _dbHelper.database;
    return await db.query(
      DatabaseHelper.tableVisits,
      where: 'status = ?',
      whereArgs: [status],
    );
  }

  Future<void> updateVisitStatusAndJobId(int id, String status, int jobId) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.tableVisits,
      {'status': status, 'job_id': jobId},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateVisitResult(int jobId, String status, {double? distance}) async {
    final db = await _dbHelper.database;
    Map<String, dynamic> values = {'status': status};
    if (distance != null) {
      values['distance'] = distance;
    }
    await db.update(
      DatabaseHelper.tableVisits,
      values,
      where: 'job_id = ?',
      whereArgs: [jobId],
    );
  }
}

// ==========================================
// 4. REPOSITORY LAYER
// ==========================================

class LandmarkRepository {
  final ApiClient _apiClient;
  final LandmarkDao _landmarkDao;
  final VisitDao _visitDao;

  LandmarkRepository(this._apiClient, this._landmarkDao, this._visitDao);

  Future<void> refreshLandmarks() async {
    try {
      final remoteLandmarks = await _apiClient.getLandmarks();
      final List<Map<String, dynamic>> toInsert = remoteLandmarks.map((dto) => {
        'id': dto.id,
        'title': dto.title,
        'lat': dto.lat,
        'lon': dto.lon,
        'image': dto.image,
        'score': dto.score,
        'visit_count': dto.visitCount,
        'avg_distance': dto.avgDistance,
        'is_deleted': 0,
      }).toList();
      await _landmarkDao.upsertLandmarks(toInsert);
    } catch (e) {
      // If network fails, serve from the local database
    }
  }

  Future<List<LandmarkDto>> getActiveLandmarks({
    String sortBy = 'score',
    bool ascending = true,
    double minScore = -double.maxFinite,
  }) async {
    final maps = await _landmarkDao.getActiveLandmarks(
      sortBy: sortBy,
      ascending: ascending,
      minScore: minScore,
    );
    return maps.map((map) => LandmarkDto(
      id: map['id'],
      title: map['title'],
      lat: map['lat'],
      lon: map['lon'],
      image: map['image'],
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      visitCount: map['visit_count'],
      avgDistance: map['avg_distance'],
    )).toList();
  }

  Future<void> createLandmark(String title, double lat, double lon, File imageFile) async {
    await _apiClient.createLandmark(title, lat, lon, imageFile);
    await refreshLandmarks();
  }

  Future<void> softDeleteLandmark(int id) async {
    await _apiClient.deleteLandmark(id);
    await _landmarkDao.softDeleteLandmark(id);
  }

  Future<void> restoreLandmark(int id) async {
    await _apiClient.restoreLandmark(id);
    await _landmarkDao.restoreLandmark(id);
  }

  Future<void> visitLandmark(LandmarkDto landmark, double lat, double lon) async {    
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      final visit = {
        'landmark_id': landmark.id,
        'landmark_title': landmark.title,
        'user_lat': lat,
        'user_lon': lon,
        'status': 'QUEUED',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };
      await _visitDao.insertVisit(visit);
      
      Workmanager().registerOneOffTask(
        'sync_offline_visits_${DateTime.now().millisecondsSinceEpoch}', 
        'syncOfflineQueue',
        constraints: Constraints(networkType: NetworkType.connected),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 1),
      );
      return;
    }

    try {
      final response = await _apiClient.visitLandmark(landmark.id, lat, lon);
      
      final visit = {
        'landmark_id': landmark.id,
        'landmark_title': landmark.title,
        'job_id': response.jobId,
        'user_lat': lat,
        'user_lon': lon,
        'status': 'PENDING',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };
      await _visitDao.insertVisit(visit);

      Workmanager().registerOneOffTask(
        'poll_${response.jobId}', 
        'pollJobStatus',
        inputData: {'jobId': response.jobId},
        constraints: Constraints(networkType: NetworkType.connected),
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(seconds: 10),
      );
    } catch (e) {
      rethrow;
    }
  }
}

// ==========================================
// 5. WORKMANAGER BACKGROUND TASK
// ==========================================

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'pollJobStatus') {
      final jobId = (inputData?['jobId'] as num?)?.toInt() ?? 0;
      if (jobId == 0) return true;
      final apiClient = ApiClient();
      final visitDao = VisitDao();

      try {
        while (true) {
          final jobStatus = await apiClient.getJobStatus(jobId);
          if (jobStatus.status == 'done') {
            await visitDao.updateVisitResult(jobId, 'DONE', distance: jobStatus.distance);
            
            try {
              final remoteLandmarks = await apiClient.getLandmarks();
              final landmarkDao = LandmarkDao();
              final List<Map<String, dynamic>> toInsert = remoteLandmarks.map((dto) => {
                'id': dto.id,
                'title': dto.title,
                'lat': dto.lat,
                'lon': dto.lon,
                'image': dto.image,
                'score': dto.score,
                'visit_count': dto.visitCount,
                'avg_distance': dto.avgDistance,
                'is_deleted': 0, 
              }).toList();
              await landmarkDao.upsertLandmarks(toInsert);
            } catch (e) {
              // Ignore failure if we cannot refresh landmarks
            }
            
            return true; 
          }
          await Future.delayed(const Duration(seconds: 2));
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          await visitDao.updateVisitResult(jobId, 'FAILED');
          return true; 
        }
        throw Exception('Network error: $e');
      } catch (e) {
        throw Exception('Unknown error: $e');
      }
    } else if (task == 'syncOfflineQueue') {
      final visitDao = VisitDao();
      final apiClient = ApiClient();
      final queuedVisits = await visitDao.getVisitsByStatus('QUEUED');
      
      for (var visit in queuedVisits) {
        try {
          final response = await apiClient.visitLandmark(visit['landmark_id'], visit['user_lat'], visit['user_lon']);
          await visitDao.updateVisitStatusAndJobId(visit['id'], 'PENDING', response.jobId);
          
          Workmanager().registerOneOffTask(
            'poll_${response.jobId}', 
            'pollJobStatus',
            inputData: {'jobId': response.jobId},
            constraints: Constraints(networkType: NetworkType.connected),
            backoffPolicy: BackoffPolicy.linear,
            backoffPolicyDelay: const Duration(seconds: 10),
          );
        } catch (e) {
          throw Exception('Failed to sync queue: $e');
        }
      }
      return true;
    }
    return true;
  });
}

// ==========================================
// 6. RIVERPOD STATE PROVIDERS
// ==========================================

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final landmarkDaoProvider = Provider<LandmarkDao>((ref) => LandmarkDao());
final visitDaoProvider = Provider<VisitDao>((ref) => VisitDao());

final landmarkRepositoryProvider = Provider<LandmarkRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final landmarkDao = ref.watch(landmarkDaoProvider);
  final visitDao = ref.watch(visitDaoProvider);
  return LandmarkRepository(apiClient, landmarkDao, visitDao);
});

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

final mapLandmarksProvider = FutureProvider<List<LandmarkDto>>((ref) async {
  final repository = ref.watch(landmarkRepositoryProvider);
  await repository.refreshLandmarks();
  return repository.getActiveLandmarks(sortBy: 'score', ascending: true);
});

final sortAscendingProvider = StateProvider<bool>((ref) => true);
final minScoreProvider = StateProvider<double>((ref) => -2000000);

final landmarksListProvider = FutureProvider<List<LandmarkDto>>((ref) async {
  final ascending = ref.watch(sortAscendingProvider);
  final minScore = ref.watch(minScoreProvider);
  final repository = ref.watch(landmarkRepositoryProvider);
  await repository.refreshLandmarks();
  return repository.getActiveLandmarks(
    sortBy: 'score', 
    ascending: ascending, 
    minScore: minScore,
  );
});

final visitsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) async* {
  yield await ref.read(visitDaoProvider).getAllVisits();
  await for (final _ in Stream.periodic(const Duration(seconds: 2))) {
    yield await ref.read(visitDaoProvider).getAllVisits();
  }
});

// ==========================================
// 7. BOTTOM NAVIGATION SHELL & MAIN APP
// ==========================================

class BottomNavScreen extends ConsumerWidget {
  const BottomNavScreen({super.key});

  static const List<Widget> _screens = [
    MapPage(),
    LandmarksPage(),
    ActivityPage(),
    AddLandmarkPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
          if (index == 0) {
            ref.invalidate(mapLandmarksProvider);
          } else if (index == 1) {
            ref.invalidate(landmarksListProvider);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Landmarks',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
        ],
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher);
  
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Geo-Tagged Landmarks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BottomNavScreen(),
    );
  }
}
