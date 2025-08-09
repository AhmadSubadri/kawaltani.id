import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart' as api;
import '../models/dashboard_data.dart';

class RealtimeScreen extends StatefulWidget {
  const RealtimeScreen({super.key});

  @override
  State<RealtimeScreen> createState() => _RealtimeScreenState();
}

class _RealtimeScreenState extends State<RealtimeScreen> {
  final storage = const FlutterSecureStorage();
  String? siteId;
  List<dynamic> areas = [];
  DashboardData? realtimeData;
  final apiService = api.ApiService();

  @override
  void initState() {
    super.initState();
    _initializeSiteId();
    _fetchAreas();
  }

  Future<void> _initializeSiteId() async {
    final storedSiteId = await storage.read(key: 'selectedSiteId');
    setState(() {
      siteId = storedSiteId;
    });
    if (siteId != null) {
      _fetchData();
    }
  }

  Future<void> _fetchAreas() async {
    try {
      if (siteId == null) return;
      final data = await apiService.getAreas(siteId!);
      setState(() {
        areas = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat daftar lahan: $e')));
    }
  }

  Future<void> _fetchData() async {
    if (siteId == null) return;
    try {
      final data = await apiService.getRealtimeData(siteId!);
      setState(() {
        realtimeData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data real-time: $e')),
      );
    }
  }

  Stream<DashboardData?> _realtimeStream() async* {
    while (true) {
      if (siteId != null) {
        try {
          final data = await apiService.getRealtimeData(siteId!);
          yield data;
        } catch (e) {
          yield null;
        }
      }
      await Future.delayed(const Duration(seconds: 5)); // Update setiap 5 detik
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Data'),
        actions: [
          if (siteId != null)
            DropdownButton<String>(
              value: siteId,
              hint: const Text('Pilih Lahan'),
              items:
                  areas.map<DropdownMenuItem<String>>((area) {
                    return DropdownMenuItem<String>(
                      value: area['site_id'].toString(),
                      child: Text(
                        area['site_name'] ?? 'Lahan ${area['site_id']}',
                      ),
                    );
                  }).toList(),
              onChanged: (value) async {
                if (value != null) {
                  setState(() {
                    siteId = value;
                  });
                  await storage.write(key: 'selectedSiteId', value: value);
                  _fetchData();
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await apiService.logout();
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Gagal logout: $e')));
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder<DashboardData?>(
        stream: _realtimeStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Data real-time tidak tersedia'));
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Realtime Data
                const Text(
                  'Data Sensor Tanah',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 8),
                if (data.soilPh?.isNotEmpty ?? false)
                  ...data.soilPh!.asMap().entries.map((entry) {
                    final index = entry.key;
                    final sensor = entry.value;
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color:
                          sensor.valueStatus == 'Danger'
                              ? Colors.red.shade600
                              : sensor.valueStatus == 'Warning'
                              ? Colors.yellow.shade600
                              : Colors.white,
                      child: ListTile(
                        title: Text(
                          'Area ${index + 1}',
                          style: TextStyle(
                            color:
                                sensor.valueStatus == 'Danger' ||
                                        sensor.valueStatus == 'Warning'
                                    ? Colors.white
                                    : Colors.grey[900],
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'pH: ${sensor.readValue} (${sensor.valueStatus})',
                              style: TextStyle(
                                color:
                                    sensor.valueStatus == 'Danger' ||
                                            sensor.valueStatus == 'Warning'
                                        ? Colors.white
                                        : Colors.grey[800],
                              ),
                            ),
                            Text(
                              'Nitrogen: ${data.nitrogen?[index].readValue ?? "N/A"} (${data.nitrogen?[index].valueStatus ?? "N/A"})',
                              style: TextStyle(
                                color:
                                    sensor.valueStatus == 'Danger' ||
                                            sensor.valueStatus == 'Warning'
                                        ? Colors.white
                                        : Colors.grey[800],
                              ),
                            ),
                            Text(
                              'Fosfor: ${data.fosfor?[index].readValue ?? "N/A"} (${data.fosfor?[index].valueStatus ?? "N/A"})',
                              style: TextStyle(
                                color:
                                    sensor.valueStatus == 'Danger' ||
                                            sensor.valueStatus == 'Warning'
                                        ? Colors.white
                                        : Colors.grey[800],
                              ),
                            ),
                            Text(
                              'Kalium: ${data.kalium?[index].readValue ?? "N/A"} (${data.kalium?[index].valueStatus ?? "N/A"})',
                              style: TextStyle(
                                color:
                                    sensor.valueStatus == 'Danger' ||
                                            sensor.valueStatus == 'Warning'
                                        ? Colors.white
                                        : Colors.grey[800],
                              ),
                            ),
                            if (sensor.valueStatus == 'Danger' ||
                                sensor.valueStatus == 'Warning')
                              Text(
                                'Aksi: ${sensor.actionMessage ?? "-"}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        trailing: Text(
                          sensor.readDate,
                          style: TextStyle(
                            color:
                                sensor.valueStatus == 'Danger' ||
                                        sensor.valueStatus == 'Warning'
                                    ? Colors.white
                                    : Colors.grey[600],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(
                      delay: Duration(milliseconds: 400 + index * 100),
                    );
                  })
                else
                  const Text(
                    'Data sensor tidak tersedia.',
                  ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          );
        },
      ),
    );
  }
}
