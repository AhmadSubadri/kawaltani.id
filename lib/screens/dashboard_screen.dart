import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart' as api;
import '../models/dashboard_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final storage = const FlutterSecureStorage();
  String? siteId;
  List<dynamic> areas = [];
  DashboardData? dashboardData;
  DashboardData? realtimeData;
  final apiService = api.ApiService();
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeSiteId();
  }

  Future<void> _initializeSiteId() async {
    final storedSiteId = await storage.read(key: 'selectedSiteId');
    print('Stored siteId: $storedSiteId');
    setState(() {
      siteId = storedSiteId;
      isLoading = true;
    });
    _fetchAreas();
  }

  Future<void> _fetchAreas() async {
    try {
      final data = await apiService.getAreas(siteId);
      print('Fetched areas: $data');
      setState(() {
        areas = data;
        isLoading = false;
        hasError = false;
      });
      if (siteId == null && data.isNotEmpty) {
        setState(() {
          siteId = data[0]['id'].toString();
        });
        await storage.write(key: 'selectedSiteId', value: siteId);
        _fetchData();
      } else if (data.isEmpty) {
        setState(() {
          hasError = true;
          errorMessage = 'Tidak ada lahan tersedia untuk site_id: $siteId';
        });
        _showSiteSelectionDialog();
      }
    } catch (e) {
      print('Error fetching areas: $e');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Gagal memuat daftar lahan: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Future<void> _fetchData() async {
    if (siteId == null) {
      print('siteId is null, cannot fetch data');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Silakan pilih lahan untuk melihat data';
      });
      return;
    }
    try {
      final dashData = await apiService.getDashboard(siteId!);
      final realData = await apiService.getRealtimeData(siteId!);
      print('Dashboard data: ${dashData.toString()}');
      print('Realtime data: ${realData.toString()}');
      setState(() {
        dashboardData = dashData;
        realtimeData = realData;
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Gagal memuat data: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Future<void> _handleLogout() async {
    try {
      await apiService.logout();
      await storage.delete(key: 'selectedSiteId');
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Logout error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal logout: $e')));
    }
  }

  void _showSiteSelectionDialog() {
    showDialog(
      context: context,
      builder:
          (context) =>
              AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.white,
                title: const Text(
                  'Pilih Lahan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                content: const Text(
                  'Silakan pilih lahan untuk melanjutkan atau hubungi administrator jika tidak ada lahan.',
                  style: TextStyle(color: Colors.teal),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms).scale(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard KawalTani',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          DropdownButton<String>(
            value: siteId,
            hint: const Text(
              'Pilih Lahan',
              style: TextStyle(color: Colors.white70),
            ),
            dropdownColor: Colors.teal.shade800,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items:
                areas.isNotEmpty
                    ? areas.map<DropdownMenuItem<String>>((area) {
                      return DropdownMenuItem<String>(
                        value: area['id'].toString(),
                        child: Text(
                          area['name'] ?? 'Lahan ${area['id']}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList()
                    : [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          'Tidak ada lahan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
            onChanged: (value) async {
              if (value != null && value != 'null') {
                print('Selected siteId: $value');
                setState(() {
                  siteId = value;
                  isLoading = true;
                  hasError = false;
                });
                await storage.write(key: 'selectedSiteId', value: value);
                _fetchData();
              }
            },
          ).animate().fadeIn(duration: 400.ms),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ).animate().fadeIn(duration: 400.ms),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              )
              : hasError
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.teal.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          hasError = false;
                        });
                        _fetchAreas();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms)
              : siteId == null || dashboardData == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 50,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pilih lahan untuk melihat data',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.teal.shade900,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms)
              : RefreshIndicator(
                onRefresh: _fetchData,
                color: Colors.teal,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Update Terakhir: ${dashboardData!.lastUpdated ?? "Tidak tersedia"}',
                              style: TextStyle(
                                color: Colors.teal.shade900,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(
                              Icons.update,
                              color: Colors.teal,
                              size: 28,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),

                      const SizedBox(height: 24),

                      // Map and Plant Info
                      // Map and Plant Info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Map
                          Expanded(
                            child: Container(
                                  height: 220,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child:
                                        dashboardData!.devices?.isNotEmpty ??
                                                false
                                            ? Image.asset(
                                              'assets/image/${dashboardData!.devices![0].devImg}',
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    color: Colors.grey.shade100,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.map,
                                                        size: 60,
                                                        color: Colors.teal,
                                                      ),
                                                    ),
                                                  ),
                                            )
                                            : Container(
                                              color: Colors.grey.shade100,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.map,
                                                  size: 60,
                                                  color: Colors.teal,
                                                ),
                                              ),
                                            ),
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .scale(begin: const Offset(0.9, 0.9)),
                          ),
                          const SizedBox(width: 16),
                          // Plant Info
                          Expanded(
                            child: Column(
                              children: [
                                _buildPlantCard(
                                  'Komoditas',
                                  dashboardData!.plants?.isNotEmpty ?? false
                                      ? dashboardData!.plants![0].commodity
                                      : 'N/A',
                                ),
                                _buildPlantCard(
                                  'Varietas',
                                  dashboardData!.plants?.isNotEmpty ?? false
                                      ? dashboardData!.plants![0].variety
                                      : 'N/A',
                                ),
                                _buildPlantCard(
                                  'Umur Tanam',
                                  dashboardData!.plants?.isNotEmpty ?? false
                                      ? '${dashboardData!.plants![0].age} HST'
                                      : 'N/A',
                                ),
                                _buildPlantCard(
                                  'Tanggal Tanam',
                                  dashboardData!.plants?.isNotEmpty ?? false
                                      ? dashboardData!.plants![0].plDatePlanting
                                      : 'N/A',
                                ),
                                _buildPlantCard(
                                  'Fase',
                                  dashboardData!.plants?.isNotEmpty ?? false
                                      ? dashboardData!.plants![0].phase
                                      : 'N/A',
                                ),
                                _buildPlantCard(
                                  'Waktu Menuju Panen',
                                  dashboardData!.plants?.isNotEmpty ?? false
                                      ? '${dashboardData!.plants![0].timeToHarvest} Hari'
                                      : 'N/A',
                                  color: Colors.green.shade600,
                                  textColor: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 600.ms),

                      const SizedBox(height: 24),

                      // Environmental Indicators
                      Text(
                        'Indikator Lingkungan',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ).animate().fadeIn(duration: 800.ms),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildIndicatorCard(
                            'Suhu',
                            dashboardData!.temperature?.isNotEmpty ?? false
                                ? '${dashboardData!.temperature![0].readValue}°C'
                                : 'N/A',
                            Icons.thermostat,
                          ),
                          _buildIndicatorCard(
                            'Kelembapan',
                            dashboardData!.humidity?.isNotEmpty ?? false
                                ? '${dashboardData!.humidity![0].readValue}%'
                                : 'N/A',
                            Icons.water_drop,
                          ),
                          _buildIndicatorCard(
                            'Angin',
                            dashboardData!.wind?.isNotEmpty ?? false
                                ? '${dashboardData!.wind![0].readValue} m/s'
                                : 'N/A',
                            Icons.air,
                          ),
                          _buildIndicatorCard(
                            'Cahaya',
                            dashboardData!.lux?.isNotEmpty ?? false
                                ? '${dashboardData!.lux![0].readValue} lux'
                                : 'N/A',
                            Icons.light_mode,
                          ),
                          _buildIndicatorCard(
                            'Hujan',
                            dashboardData!.rain?.isNotEmpty ?? false
                                ? '${dashboardData!.rain![0].readValue} mm'
                                : 'N/A',
                            Icons.water,
                          ),
                        ],
                      ).animate().fadeIn(duration: 1000.ms),

                      const SizedBox(height: 24),

                      // Tasks and Warnings
                      Text(
                        'Tugas & Peringatan',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ).animate().fadeIn(duration: 1200.ms),
                      const SizedBox(height: 12),
                      // Tasks
                      if (dashboardData!.todos?.isNotEmpty ?? false)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tugas',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.teal.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...dashboardData!.todos!.expand(
                              (todoGroup) => todoGroup.todos.map(
                                (todo) => Card(
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.task_alt,
                                          color: Colors.teal,
                                        ),
                                        title: Text(
                                          todo.handTitle,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Waktu: ${todo.todoDate}'),
                                            Text(
                                              'Pupuk: ${todo.fertilizerType}',
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(duration: 300.ms)
                                    .slideX(begin: 0.2),
                              ),
                            ),
                          ],
                        )
                      else
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Tidak ada tugas saat ini.'),
                          ),
                        ).animate().fadeIn(duration: 300.ms),

                      const SizedBox(height: 16),
                      // Warnings
                      if ((dashboardData!.temperature?.isNotEmpty ?? false) ||
                          (dashboardData!.humidity?.isNotEmpty ?? false) ||
                          (realtimeData!.soilPh?.isNotEmpty ?? false) ||
                          (realtimeData!.nitrogen?.isNotEmpty ?? false) ||
                          (realtimeData!.fosfor?.isNotEmpty ?? false) ||
                          (realtimeData!.kalium?.isNotEmpty ?? false))
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Peringatan',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.teal.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._buildWarningCards(),
                          ],
                        )
                      else
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Semua sensor dalam kondisi baik.'),
                          ),
                        ).animate().fadeIn(duration: 300.ms),

                      const SizedBox(height: 24),

                      // Realtime Data
                      Text(
                        'Realtime',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ).animate().fadeIn(duration: 1400.ms),
                      const SizedBox(height: 12),
                      if (realtimeData!.soilPh?.isNotEmpty ?? false)
                        ...realtimeData!.soilPh!.asMap().entries.map((entry) {
                          final index = entry.key;
                          final sensor = entry.value;
                          return Card(
                            elevation: 6,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color:
                                sensor.valueStatus == 'Danger'
                                    ? Colors.red.shade600
                                    : sensor.valueStatus == 'Warning'
                                    ? Colors.yellow.shade600
                                    : Colors.white,
                            child: ListTile(
                              leading: const Icon(
                                Icons.sensors,
                                color: Colors.teal,
                              ),
                              title: Text(
                                'Area ${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      sensor.valueStatus == 'Danger' ||
                                              sensor.valueStatus == 'Warning'
                                          ? Colors.white
                                          : Colors.teal.shade900,
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
                                                  sensor.valueStatus ==
                                                      'Warning'
                                              ? Colors.white
                                              : Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    'Nitrogen: ${realtimeData!.nitrogen?[index].readValue ?? "N/A"} (${realtimeData!.nitrogen?[index].valueStatus ?? "N/A"})',
                                    style: TextStyle(
                                      color:
                                          sensor.valueStatus == 'Danger' ||
                                                  sensor.valueStatus ==
                                                      'Warning'
                                              ? Colors.white
                                              : Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    'Fosfor: ${realtimeData!.fosfor?[index].readValue ?? "N/A"} (${realtimeData!.fosfor?[index].valueStatus ?? "N/A"})',
                                    style: TextStyle(
                                      color:
                                          sensor.valueStatus == 'Danger' ||
                                                  sensor.valueStatus ==
                                                      'Warning'
                                              ? Colors.white
                                              : Colors.grey[800],
                                    ),
                                  ),
                                  Text(
                                    'Kalium: ${realtimeData!.kalium?[index].readValue ?? "N/A"} (${realtimeData!.kalium?[index].valueStatus ?? "N/A"})',
                                    style: TextStyle(
                                      color:
                                          sensor.valueStatus == 'Danger' ||
                                                  sensor.valueStatus ==
                                                      'Warning'
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
                            ),
                          ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2);
                        })
                      else
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Data sensor tidak tersedia.'),
                          ),
                        ).animate().fadeIn(duration: 300.ms),

                      const SizedBox(height: 24),

                      // Chart
                      Text(
                        'Grafik Suhu dan Kelembapan',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ).animate().fadeIn(duration: 1600.ms),
                      const SizedBox(height: 12),
                      Container(
                        height: 280,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: LineChart(
                          LineChartData(
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget:
                                      (value, meta) => Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.teal,
                                        ),
                                      ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget:
                                      (value, meta) => Text(
                                        'Data ${value.toInt() + 1}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.teal,
                                        ),
                                      ),
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.teal.shade200),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              horizontalInterval: 10,
                              verticalInterval: 1,
                              getDrawingHorizontalLine:
                                  (value) => FlLine(
                                    color: Colors.teal.shade100,
                                    strokeWidth: 1,
                                  ),
                              getDrawingVerticalLine:
                                  (value) => FlLine(
                                    color: Colors.teal.shade100,
                                    strokeWidth: 1,
                                  ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots:
                                    dashboardData!.temperature
                                        ?.asMap()
                                        .entries
                                        .map((e) {
                                          return FlSpot(
                                            e.key.toDouble(),
                                            e.value.readValue,
                                          );
                                        })
                                        .toList() ??
                                    [],
                                isCurved: true,
                                color: Colors.teal.shade600,
                                barWidth: 3,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.teal.shade100.withOpacity(0.3),
                                ),
                              ),
                              LineChartBarData(
                                spots:
                                    dashboardData!.humidity
                                        ?.asMap()
                                        .entries
                                        .map((e) {
                                          return FlSpot(
                                            e.key.toDouble(),
                                            e.value.readValue,
                                          );
                                        })
                                        .toList() ??
                                    [],
                                isCurved: true,
                                color: Colors.blue.shade600,
                                barWidth: 3,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.blue.shade100.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 1800.ms).scale(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildPlantCard(
    String title,
    String value, {
    Color? color,
    Color? textColor,
  }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color ?? Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.eco, color: textColor ?? Colors.teal.shade700, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Colors.teal.shade800,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor ?? Colors.teal.shade900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2);
  }

  Widget _buildIndicatorCard(String title, String value, IconData icon) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: (MediaQuery.of(context).size.width - 44) / 2, // Responsive width
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal.shade700, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale();
  }

  List<Widget> _buildWarningCards() {
    List<Widget> warnings = [];
    if ((dashboardData!.temperature?.isNotEmpty ?? false) &&
        [
          'Warning',
          'Danger',
        ].contains(dashboardData!.temperature![0].valueStatus)) {
      warnings.add(
        _buildWarningCard(
          dashboardData!.temperature![0].sensorName ?? 'Suhu',
          dashboardData!.temperature![0].statusMessage ?? '',
          dashboardData!.temperature![0].actionMessage ?? '',
          dashboardData!.temperature![0].valueStatus ?? '',
        ),
      );
    }
    if ((dashboardData!.humidity?.isNotEmpty ?? false) &&
        [
          'Warning',
          'Danger',
        ].contains(dashboardData!.humidity![0].valueStatus)) {
      warnings.add(
        _buildWarningCard(
          dashboardData!.humidity![0].sensorName ?? 'Kelembapan',
          dashboardData!.humidity![0].statusMessage ?? '',
          dashboardData!.humidity![0].actionMessage ?? '',
          dashboardData!.humidity![0].valueStatus ?? '',
        ),
      );
    }
    if (realtimeData!.soilPh?.isNotEmpty ?? false) {
      for (var sensor in realtimeData!.soilPh!) {
        if (['Warning', 'Danger'].contains(sensor.valueStatus)) {
          warnings.add(
            _buildWarningCard(
              sensor.sensorName,
              sensor.statusMessage,
              sensor.actionMessage ?? '',
              sensor.valueStatus,
            ),
          );
        }
      }
    }
    if (realtimeData!.nitrogen?.isNotEmpty ?? false) {
      for (var sensor in realtimeData!.nitrogen!) {
        if (['Warning', 'Danger'].contains(sensor.valueStatus)) {
          warnings.add(
            _buildWarningCard(
              sensor.sensorName,
              sensor.statusMessage,
              sensor.actionMessage ?? '',
              sensor.valueStatus,
            ),
          );
        }
      }
    }
    if (realtimeData!.fosfor?.isNotEmpty ?? false) {
      for (var sensor in realtimeData!.fosfor!) {
        if (['Warning', 'Danger'].contains(sensor.valueStatus)) {
          warnings.add(
            _buildWarningCard(
              sensor.sensorName,
              sensor.statusMessage,
              sensor.actionMessage ?? '',
              sensor.valueStatus,
            ),
          );
        }
      }
    }
    if (realtimeData!.kalium?.isNotEmpty ?? false) {
      for (var sensor in realtimeData!.kalium!) {
        if (['Warning', 'Danger'].contains(sensor.valueStatus)) {
          warnings.add(
            _buildWarningCard(
              sensor.sensorName,
              sensor.statusMessage,
              sensor.actionMessage ?? '',
              sensor.valueStatus,
            ),
          );
        }
      }
    }
    return warnings
        .map(
          (card) => card.animate().fadeIn(duration: 300.ms).slideX(begin: 0.2),
        )
        .toList();
  }

  Widget _buildWarningCard(
    String sensorName,
    String statusMessage,
    String actionMessage,
    String valueStatus,
  ) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color:
          valueStatus == 'Danger'
              ? Colors.red.shade600
              : Colors.yellow.shade600,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              statusMessage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Indikator: $sensorName',
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            Text(
              'Aksi: $actionMessage',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
