import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../database/database.dart';

class StatisticsScreen extends StatefulWidget {
  final AppDatabase database;
  const StatisticsScreen({super.key, required this.database});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedPeriodDays = 7;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: _selectedPeriodDays - 1));

    return Column(
      children: [
        _buildPeriodSelector(),
        Expanded(
          child: StreamBuilder<List<DailySleepRecord>>(
            stream: widget.database.watchRecordsInPeriod(start, now),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final records = snapshot.data ?? [];
              
              if (records.isEmpty) {
                return const Center(
                  child: Text(
                    "기록된 데이터가 없습니다.\n버튼을 눌러 수면제를 복용해 보세요.",
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "수면제 복용 시간 추이",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text("Y축: 시간 (00:00~23:59), X축: 날짜"),
                    const SizedBox(height: 24),
                    Expanded(child: _buildMedicationChart(records)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8,
        children: [7, 14, 30].map((days) {
          return ChoiceChip(
            label: Text("$days일"), // {} 제거하여 경고 해결
            selected: _selectedPeriodDays == days,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedPeriodDays = days);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMedicationChart(List<DailySleepRecord> records) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 24,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) => const FlLine(color: Colors.grey, strokeWidth: 0.5),
          drawVerticalLine: false,
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < records.length) {
                  final date = DateFormat('yyyy-MM-dd').parse(records[index].date);
                  return Text(DateFormat('MM/dd').format(date), style: const TextStyle(fontSize: 10));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 4,
              getTitlesWidget: (value, meta) => Text("${value.toInt()}시", style: const TextStyle(fontSize: 10)),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _generateSpots(records),
            isCurved: false,
            color: Colors.indigo,
            barWidth: 2,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateSpots(List<DailySleepRecord> records) {
    List<FlSpot> spots = [];
    for (int i = 0; i < records.length; i++) {
      final record = records[i];
      if (record.medications != null && record.medications!.isNotEmpty) {
        final timeStr = record.medications![0]['time'] as String;
        final timeParts = timeStr.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final timeValue = hour + (minute / 60.0);
        spots.add(FlSpot(i.toDouble(), timeValue));
      }
    }
    return spots;
  }
}
