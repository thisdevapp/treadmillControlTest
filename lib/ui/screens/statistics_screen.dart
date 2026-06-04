import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import '../../database/database.dart';
import '../widgets/custom_picker_utils.dart';

/// 모든 차트 요소의 크기와 패딩을 중앙 관리하는 클래스
class _ChartMetrics {
  final double barWidth;
  final double medRadius;
  final double labelFontSize;
  final double dateFontSize;
  final double valueFontSize;
  final double topPadding;

  factory _ChartMetrics(double dayWidth) {
    double bw = (dayWidth * 0.75).clamp(6.0, 150.0);
    bw = (bw * 2).roundToDouble() / 2.0; 

    final double lfs = (bw * 0.25 + 6).clamp(8.0, 30.0); 
    final double dfs = (bw * 0.5 + 7).clamp(10.0, 60.0);  
    final double vfs = (bw * 0.3 + 4).clamp(7.0, 32.0);  
    
    final double calculatedTopPadding = lfs + dfs;
    
    return _ChartMetrics._(
      barWidth: bw,
      medRadius: bw / 2.0,
      labelFontSize: lfs,
      dateFontSize: dfs,
      valueFontSize: vfs,
      topPadding: calculatedTopPadding.clamp(20.0, 150.0),
    );
  }

  _ChartMetrics._({
    required this.barWidth,
    required this.medRadius,
    required this.labelFontSize,
    required this.dateFontSize,
    required this.valueFontSize,
    required this.topPadding,
  });
}

class _StaticYAxisPainter extends CustomPainter {
  final _ChartMetrics metrics;
  final bool isDarkMode;

  _StaticYAxisPainter({required this.metrics, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    const double bottomPadding = 30.0;
    final double chartHeight = size.height - metrics.topPadding - bottomPadding;

    for (int h = 0; h <= 24; h += 6) {
      double y = metrics.topPadding + (h / 24.0) * chartHeight;
      final tpYLabel = _getTextPainter(
        "${h.toString().padLeft(2, '0')}:00", 
        (metrics.labelFontSize * 0.9).clamp(9, 15), 
        Colors.grey
      );
      
      canvas.save();
      canvas.translate(size.width / 2, y);
      canvas.rotate(math.pi / 2);
      tpYLabel.paint(canvas, Offset(-tpYLabel.width / 2, -tpYLabel.height / 2));
      canvas.restore();
    }
  }

  TextPainter _getTextPainter(String text, double fontSize, Color color) {
    return TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
  }

  @override
  bool shouldRepaint(covariant _StaticYAxisPainter oldDelegate) => 
      oldDelegate.metrics.topPadding != metrics.topPadding || oldDelegate.isDarkMode != isDarkMode;
}

class _HitInfo {
  final int recordId;
  final String hitType;
  final String titleText;
  final String subtitleText;
  final Offset targetPos;
  final String displayDate;

  _HitInfo({
    required this.recordId,
    required this.hitType,
    required this.titleText,
    required this.subtitleText,
    required this.targetPos,
    required this.displayDate,
  });
}

class StatisticsScreen extends StatefulWidget {
  final AppDatabase database;
  final double longPressSeconds;

  const StatisticsScreen({
    super.key, 
    required this.database, 
    required this.longPressSeconds,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedPeriodDays = 7;
  late PageController _pageController;
  int _currentPageIndex = 0; 
  bool _isMenuOpen = false;
  bool _showAllDetails = false; 

  static const double yAxisWidth = 35.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedPeriodDays = prefs.getInt('statistics_period') ?? 7;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _savePeriod(int days, {int? targetPage}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('statistics_period', days);
    if (mounted) {
      setState(() {
        _selectedPeriodDays = days;
        _currentPageIndex = targetPage ?? 0;
        _pageController.jumpToPage(_currentPageIndex);
      });
    }
  }

  void _movePage(int delta) {
    final target = _currentPageIndex + delta;
    if (target < 0) return;
    
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuart,
    );
  }

  void _resetToToday() {
    if (_currentPageIndex == 0) return;
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
    );
  }

  Future<void> _pickStartDate(DateTime currentStart, DateTime currentEnd, DateTime baseDate) async {
    final picked = await CustomPickerUtils.pickDate(
      context: context,
      initialDate: currentStart,
      lastDate: currentEnd, 
      helpText: "시작 날짜 선택",
    );
    if (picked != null) {
      final newPeriod = currentEnd.difference(picked).inDays + 1;
      if (newPeriod > 0) {
        final daysFromToday = baseDate.difference(currentEnd).inDays;
        final newIndex = daysFromToday ~/ newPeriod;
        _savePeriod(newPeriod, targetPage: newIndex);
      }
    }
  }

  Future<void> _pickEndDate(DateTime currentEnd, DateTime currentStart, DateTime baseDate) async {
    final picked = await CustomPickerUtils.pickDate(
      context: context,
      initialDate: currentEnd,
      firstDate: currentStart, 
      lastDate: DateTime.now(),
      helpText: "끝 날짜 선택",
    );
    if (picked != null) {
      final daysFromToday = baseDate.difference(picked).inDays;
      final newIndex = daysFromToday ~/ _selectedPeriodDays;
      setState(() {
        _currentPageIndex = newIndex;
        _pageController.jumpToPage(newIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final DateTime baseDate = DateTime(today.year, today.month, today.day);
    
    final daysOffset = _currentPageIndex * _selectedPeriodDays;
    final displayEndDate = baseDate.subtract(Duration(days: daysOffset));
    final displayStartDate = displayEndDate.subtract(Duration(days: _selectedPeriodDays - 1));

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8), 
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              _buildAnimatedHeader(displayStartDate, displayEndDate, baseDate),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double dataAreaWidth = constraints.maxWidth - yAxisWidth;
                    final double dayWidth = dataAreaWidth / _selectedPeriodDays;
                    final metrics = _ChartMetrics(dayWidth);

                    return Row(
                      children: [
                        SizedBox(
                          width: yAxisWidth,
                          height: double.infinity,
                          child: CustomPaint(
                            painter: _StaticYAxisPainter(
                              metrics: metrics,
                              isDarkMode: Theme.of(context).brightness == Brightness.dark,
                            ),
                          ),
                        ),
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            reverse: true, 
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: (index) {
                              setState(() {
                                _currentPageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return _StatisticsPageContent(
                                database: widget.database,
                                pageIndex: index,
                                periodDays: _selectedPeriodDays,
                                showAllDetails: _showAllDetails,
                                longPressSeconds: widget.longPressSeconds,
                                onExecuteLongPress: _executeLongPress,
                                yAxisWidth: 0, 
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              _buildLegend(),
            ],
          ),
          if (_isMenuOpen)
            GestureDetector(
              onTap: () => setState(() => _isMenuOpen = false),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          _buildFabMenu(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [7, 14, 30].map((days) {
              return Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: ChoiceChip(
                  label: Text("$days일", style: const TextStyle(fontSize: 11)),
                  selected: _selectedPeriodDays == days,
                  onSelected: (selected) {
                    if (selected) _savePeriod(days);
                  },
                  padding: EdgeInsets.zero,
                ),
              );
            }).toList(),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _resetToToday,
                icon: const Icon(Icons.today_outlined, size: 18),
                tooltip: "오늘로 이동",
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              IconButton(
                onPressed: () => setState(() => _showAllDetails = !_showAllDetails),
                icon: Icon(
                  _showAllDetails ? Icons.segment : Icons.segment_outlined,
                  color: _showAllDetails ? Colors.indigo : null,
                  size: 18,
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              IconButton.filledTonal(
                onPressed: () => setState(() => _isMenuOpen = !_isMenuOpen),
                icon: Icon(_isMenuOpen ? Icons.close : Icons.add, size: 18),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader(DateTime start, DateTime end, DateTime baseDate) {
    final f = DateFormat('yyyy.MM.dd');
    final isTodayPage = _currentPageIndex == 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 20),
          onPressed: () => _movePage(1),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(4),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: ValueKey<String>("${_currentPageIndex}_$_selectedPeriodDays"), 
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1), 
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDateClickableText(f.format(start), () => _pickStartDate(start, end, baseDate)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Text("~", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                _buildDateClickableText(f.format(end), () => _pickEndDate(end, start, baseDate)),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 20),
          onPressed: isTodayPage ? null : () => _movePage(-1),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(4),
        ),
      ],
    );
  }

  Widget _buildDateClickableText(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 12, 
            color: Colors.indigo,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return FutureBuilder<List<CustomDataType>>(
      future: widget.database.getCustomDataTypes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final types = snapshot.data!;
        
        return Wrap(
          spacing: 12,
          runSpacing: 4,
          children: types.map((t) {
            final color = Color(t.colorValue ?? 0xFF3F51B5);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9, 
                  height: 9, 
                  decoration: BoxDecoration(color: color.withOpacity(0.8), shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(t.name, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildFabMenu() {
    if (!_isMenuOpen) return const SizedBox.shrink();
    return Positioned(
      top: 80, 
      right: 16, 
      child: Material(
        elevation: 8, 
        borderRadius: BorderRadius.circular(12), 
        child: FutureBuilder<List<CustomDataType>>(
          future: widget.database.getCustomDataTypes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final types = snapshot.data!;
            final sleepType = types.firstWhere((t) => t.isPreset && t.name == '수면', orElse: () => types[0]);
            final otherTypes = types.where((t) => t.id != sleepType.id).toList();

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _menuItem(Icons.bedtime, "수면 기록 추가", () => _pickSleepPeriod(sleepType.id)),
                if (otherTypes.isNotEmpty) ...[
                  const Divider(height: 1),
                  ...otherTypes.map((type) {
                    return _menuItem(
                      _getIconData(type.iconName),
                      "${type.name} 추가",
                      () => _pickCustomEventTime(type),
                    );
                  })
                ]
              ],
            );
          },
        ),
      ),
    );
  }

  IconData _getIconData(String? name) {
    switch (name) {
      case 'hotel': return Icons.hotel;
      case 'medication': return Icons.medication;
      case 'coffee': return Icons.local_cafe;
      case 'smoke': return Icons.smoking_rooms;
      case 'sports': return Icons.directions_run;
      case 'beer': return Icons.local_bar;
      case 'star': return Icons.star;
      case 'favorite': return Icons.favorite;
      case 'mood': return Icons.mood;
      default: return Icons.category;
    }
  }

  Widget _menuItem(IconData i, String l, VoidCallback t) => InkWell(
    onTap: () { 
      setState(() => _isMenuOpen = false); 
      t(); 
    }, 
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(i, size: 18, color: Colors.indigo), 
          const SizedBox(width: 10), 
          Text(l, style: const TextStyle(fontSize: 13)),
        ],
      ),
    ),
  );

  Future<void> _pickCustomEventTime(CustomDataType type) async {
    final d = await CustomPickerUtils.pickDate(context: context, initialDate: DateTime.now());
    if (d == null) return;
    final t = await CustomPickerUtils.pickTime(context: context, initialTime: TimeOfDay.now());
    if (t == null) return;
    
    final finalTime = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    
    if (mounted) {
      final memoController = TextEditingController();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("${type.name} 입력"),
          content: TextField(
            controller: memoController,
            decoration: const InputDecoration(
              labelText: "추가 세부 사항 (선택)",
              hintText: "예: 졸피뎀 10mg, 아메리카노 등",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
            FilledButton(
              onPressed: () async {
                await widget.database.addCustomDataRecord(
                  typeId: type.id,
                  timestamp: finalTime,
                  value: memoController.text.trim().isEmpty ? null : memoController.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text("저장"),
            )
          ],
        ),
      );
    }
  }

  Future<void> _pickSleepPeriod(int sleepTypeId) async {
    final d = await CustomPickerUtils.pickDate(context: context, initialDate: DateTime.now());
    if (d == null) return;
    final sT = await CustomPickerUtils.pickTime(context: context, initialTime: const TimeOfDay(hour: 22, minute: 0), helpText: "수면 시작");
    if (sT == null) return;
    final eT = await CustomPickerUtils.pickTime(context: context, initialTime: const TimeOfDay(hour: 7, minute: 0), helpText: "기상 시각");
    if (eT == null) return;
    
    final start = DateTime(d.year, d.month, d.day, sT.hour, sT.minute);
    var end = DateTime(d.year, d.month, d.day, eT.hour, eT.minute);
    if (end.isBefore(start)) end = end.add(const Duration(days: 1));

    if (mounted) {
      int quality = 3;
      final memoController = TextEditingController();

      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setStateDlg) => AlertDialog(
            title: const Text("수면 만족도 기입"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("만족도를 탭해서 선택하세요:"),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (idx) {
                    return IconButton(
                      icon: Icon(idx < quality ? Icons.star : Icons.star_border, color: Colors.amber, size: 28),
                      onPressed: () => setStateDlg(() => quality = idx + 1),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: memoController,
                  decoration: const InputDecoration(labelText: "수면 특이사항 메모 (선택)", border: OutlineInputBorder()),
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
              FilledButton(
                onPressed: () async {
                  final valueJson = json.encode({
                    'endUnix': end.millisecondsSinceEpoch ~/ 1000,
                    'quality': quality,
                    'memo': memoController.text.trim(),
                  });
                  await widget.database.addCustomDataRecord(
                    typeId: sleepTypeId,
                    timestamp: start,
                    value: valueJson,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text("완료"),
              )
            ],
          ),
        ),
      );
    }
  }

  void _executeLongPress(_HitInfo hit) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(hit.titleText), 
      content: Text("${hit.subtitleText}\n\n정말로 이 기록을 완전히 삭제하시겠습니까?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
        TextButton(onPressed: () async {
          await widget.database.deleteCustomDataRecord(hit.recordId);
          if(mounted) Navigator.pop(ctx);
        }, child: const Text("삭제", style: TextStyle(color: Colors.red))),
      ],
    ));
  }
}

class _StatisticsPageContent extends StatefulWidget {
  final AppDatabase database;
  final int pageIndex;
  final int periodDays;
  final bool showAllDetails;
  final double longPressSeconds;
  final double yAxisWidth;
  final Function(_HitInfo) onExecuteLongPress;

  const _StatisticsPageContent({
    required this.database,
    required this.pageIndex,
    required this.periodDays,
    required this.showAllDetails,
    required this.longPressSeconds,
    required this.yAxisWidth,
    required this.onExecuteLongPress,
  });

  @override
  State<_StatisticsPageContent> createState() => _StatisticsPageContentState();
}

class _StatisticsPageContentState extends State<_StatisticsPageContent> {
  Stream<Map<String, dynamic>>? _pageStream;
  Timer? _longPressTimer;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  @override
  void didUpdateWidget(_StatisticsPageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageIndex != widget.pageIndex || oldWidget.periodDays != widget.periodDays) {
      _initStream();
    }
  }

  void _initStream() {
    final DateTime today = DateTime.now();
    final DateTime baseDate = DateTime(today.year, today.month, today.day);
    final daysOffset = widget.pageIndex * widget.periodDays;
    final end = baseDate.subtract(Duration(days: daysOffset));
    final endOfWindow = DateTime(end.year, end.month, end.day, 23, 59, 59);
    final startOfWindow = endOfWindow.subtract(Duration(days: widget.periodDays + 1)); 

    _pageStream = Rx.combineLatest2(
      widget.database.watchRecordsInPeriod(startOfWindow, endOfWindow),
      widget.database.watchCustomDataTypes(),
      (List<CustomDataRecord> records, List<CustomDataType> types) => {
        'records': records, 
        'types': types,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final DateTime baseDate = DateTime(today.year, today.month, today.day);
    final daysOffset = widget.pageIndex * widget.periodDays;
    final end = baseDate.subtract(Duration(days: daysOffset));
    final start = end.subtract(Duration(days: widget.periodDays - 1));
    final pageDates = List.generate(widget.periodDays, (i) => start.add(Duration(days: i)));

    return StreamBuilder<Map<String, dynamic>>(
      stream: _pageStream,
      builder: (context, snapshot) {
        final List<CustomDataRecord> records = snapshot.hasData ? List<CustomDataRecord>.from(snapshot.data!['records'] as Iterable) : <CustomDataRecord>[];
        final List<CustomDataType> types = snapshot.hasData ? List<CustomDataType>.from(snapshot.data!['types'] as Iterable) : <CustomDataType>[];

        return LayoutBuilder(
          builder: (context, constraints) {
            final double dayWidth = (constraints.maxWidth - widget.yAxisWidth) / pageDates.length;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                final hit = _checkHit(details.localPosition, pageDates, records, types, dayWidth, widget.yAxisWidth, constraints.maxHeight);
                if (hit != null) {
                  _longPressTimer?.cancel();
                  _longPressTimer = Timer(Duration(milliseconds: (widget.longPressSeconds * 1000).toInt()), () => widget.onExecuteLongPress(hit));
                }
              },
              onTapUp: (_) => _longPressTimer?.cancel(),
              onTapCancel: () => _longPressTimer?.cancel(),
              child: CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: SleepTimelinePainter(
                  allDates: pageDates,
                  records: records,
                  types: types,
                  isDarkMode: Theme.of(context).brightness == Brightness.dark,
                  dayWidth: dayWidth,
                  showAllDetails: widget.showAllDetails,
                  yAxisWidth: widget.yAxisWidth,
                ),
              ),
            );
          },
        );
      },
    );
  }

  _HitInfo? _checkHit(Offset pos, List<DateTime> dates, List<CustomDataRecord> records, List<CustomDataType> types, double dayWidth, double left, double height) {
    if (types.isEmpty) return null;
    final metrics = _ChartMetrics(dayWidth);
    
    const double bottomPadding = 30.0;
    final double chartHeight = height - metrics.topPadding - bottomPadding;
    final double x = pos.dx - left;
    if (x < 0) return null;

    final int dayIdx = (x / dayWidth).floor();
    if (dayIdx < 0 || dayIdx >= dates.length) return null;
    final targetDate = dates[dayIdx];

    final sleepType = types.firstWhere((t) => t.isPreset && t.name == '수면', orElse: () => types[0]);
    final double centerX = (left + (dayIdx * dayWidth) + (dayWidth / 2)).roundToDouble();

    // targetDate는 로컬 00:00이므로, dayStartUnix는 해당 시점의 UTC Epoch입니다.
    final dayStartUnix = targetDate.millisecondsSinceEpoch ~/ 1000;
    
    for (var r in records) {
      final type = types.firstWhere((t) => t.id == r.typeId, orElse: () => types[0]);
      
      if (type.id == sleepType.id) {
        int? endUnix;
        if (r.value != null) {
          try { endUnix = json.decode(r.value!)['endUnix'] as int?; } catch (_) { endUnix = int.tryParse(r.value!); }
        }
        final sLocalEnd = endUnix ?? r.unixTimestamp;
        
        final drawStart = math.max(r.unixTimestamp, dayStartUnix);
        final drawEnd = math.min(sLocalEnd, dayStartUnix + 86400);

        if (drawStart < drawEnd) {
          final double startY = metrics.topPadding + ((drawStart - dayStartUnix) / 86400.0) * chartHeight;
          final double endY = metrics.topPadding + ((drawEnd - dayStartUnix) / 86400.0) * chartHeight;
          
          if (pos.dx >= centerX - metrics.barWidth/2 && pos.dx <= centerX + metrics.barWidth/2 && pos.dy >= startY && pos.dy <= endY) {
            final dtS = DateTime.fromMillisecondsSinceEpoch((r.unixTimestamp + r.offsetSeconds) * 1000, isUtc: true);
            final dtE = DateTime.fromMillisecondsSinceEpoch((sLocalEnd + r.offsetSeconds) * 1000, isUtc: true);
            final durationStr = "${(sLocalEnd - r.unixTimestamp) ~/ 3600}시간 ${((sLocalEnd - r.unixTimestamp) % 3600) ~/ 60}분";
            return _HitInfo(
              recordId: r.id,
              hitType: 'sleep',
              titleText: "수면 기록 삭제",
              subtitleText: "기록 범위: ${DateFormat('HH:mm').format(dtS)} ~ ${DateFormat('HH:mm').format(dtE)} ($durationStr)",
              targetPos: Offset(centerX, pos.dy),
              displayDate: DateFormat('yyyy-MM-dd').format(targetDate),
            );
          }
        }
      } else {
        // 해당 날짜 범위에 있는지 검사
        if (r.unixTimestamp >= dayStartUnix && r.unixTimestamp < dayStartUnix + 86400) {
          final double fractionalDay = (r.unixTimestamp - dayStartUnix) / 86400.0;
          final double y = metrics.topPadding + fractionalDay * chartHeight;
          final double touchTargetRadius = (metrics.medRadius * 2.0).clamp(20.0, 60.0);
          
          if ((pos - Offset(centerX, y)).distance <= touchTargetRadius) {
            final dt = DateTime.fromMillisecondsSinceEpoch((r.unixTimestamp + r.offsetSeconds) * 1000, isUtc: true);
            final timeText = DateFormat('HH:mm').format(dt);
            return _HitInfo(
              recordId: r.id,
              hitType: 'custom',
              titleText: "${type.name} 기록 삭제",
              subtitleText: "시각: $timeText\n내용: ${r.value ?? '단순 기록'}",
              targetPos: Offset(centerX, y),
              displayDate: DateFormat('yyyy-MM-dd').format(targetDate),
            );
          }
        }
      }
    }
    return null;
  }
}

class SleepTimelinePainter extends CustomPainter {
  final List<DateTime> allDates;
  final List<CustomDataRecord> records;
  final List<CustomDataType> types;
  final bool isDarkMode;
  final double dayWidth;
  final bool showAllDetails;
  final double yAxisWidth;

  SleepTimelinePainter({
    required this.allDates, 
    required this.records, 
    required this.types, 
    required this.isDarkMode, 
    required this.dayWidth, 
    required this.showAllDetails, 
    required this.yAxisWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (types.isEmpty) return;
    final metrics = _ChartMetrics(dayWidth);
    const double bottomPadding = 30.0;
    final double chartHeight = size.height - metrics.topPadding - bottomPadding;

    final gridPaint = Paint()..color = isDarkMode ? Colors.white12 : Colors.black12..strokeWidth = 1;

    for (int h = 0; h <= 24; h += 6) {
      double y = metrics.topPadding + (h / 24.0) * chartHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final sleepType = types.firstWhere((t) => t.isPreset && t.name == '수면', orElse: () => types[0]);

    for (int i = 0; i < allDates.length; i++) {
      final date = allDates[i];
      final double centerX = (i * dayWidth) + (dayWidth / 2);

      final tpLabel = _getTextPainter(DateFormat('E', 'ko_KR').format(date), metrics.labelFontSize, Colors.grey);
      final tpDate = _getTextPainter(DateFormat('dd').format(date), metrics.dateFontSize, isDarkMode ? Colors.white : Colors.black, isBold: true);
      
      _drawTextWithPainter(canvas, tpLabel, Offset(centerX - tpLabel.width / 2, 0));
      _drawTextWithPainter(canvas, tpDate, Offset(centerX - tpDate.width / 2, tpLabel.height - 4.0));

      canvas.drawLine(Offset(centerX, metrics.topPadding), Offset(centerX, metrics.topPadding + chartHeight), gridPaint);

      final dayStartUnix = date.millisecondsSinceEpoch ~/ 1000;
      final List<math.Rectangle<double>> occupiedAreas = [];

      final dayRecords = records.where((r) {
        // r.unixTimestamp는 UTC Epoch
        // dayStartUnix는 해당 날짜 로컬 00:00의 UTC Epoch
        // 따라서 단순히 r.unixTimestamp가 [dayStartUnix, dayStartUnix + 86400) 사이에 있는지 확인하면 됩니다.
        return r.unixTimestamp >= dayStartUnix && r.unixTimestamp < dayStartUnix + 86400;
      }).toList();

      final sleepPaints = dayRecords.where((r) => r.typeId == sleepType.id).toList();
      final sleepPaint = Paint()..color = Color(sleepType.colorValue ?? 0xFF4CAF50).withOpacity(0.7)..style = PaintingStyle.fill;

      for (var r in sleepPaints) {
        int? endUnix;
        if (r.value != null) {
          try { endUnix = json.decode(r.value!)['endUnix'] as int?; } catch (_) { endUnix = int.tryParse(r.value!); }
        }
        final sLocalEnd = endUnix ?? r.unixTimestamp;
        
        final drawStart = math.max(r.unixTimestamp, dayStartUnix);
        final drawEnd = math.min(sLocalEnd, dayStartUnix + 86400);

        if (drawStart < drawEnd) {
          final double startY = metrics.topPadding + ((drawStart - dayStartUnix) / 86400.0) * chartHeight;
          final double endY = metrics.topPadding + ((drawEnd - dayStartUnix) / 86400.0) * chartHeight;
          final double cornerRadius = metrics.barWidth / 2;

          canvas.drawRRect(RRect.fromRectAndCorners(
            Rect.fromLTRB(centerX - metrics.barWidth/2, startY, centerX + metrics.barWidth/2, endY), 
            topLeft: r.unixTimestamp >= dayStartUnix ? Radius.circular(cornerRadius) : Radius.zero, 
            topRight: r.unixTimestamp >= dayStartUnix ? Radius.circular(cornerRadius) : Radius.zero, 
            bottomLeft: sLocalEnd <= dayStartUnix + 86400 ? Radius.circular(cornerRadius) : Radius.zero, 
            bottomRight: sLocalEnd <= dayStartUnix + 86400 ? Radius.circular(cornerRadius) : Radius.zero
          ), sleepPaint);

          if (showAllDetails) {
            final tpS = _getTextPainter(_formatUnix(r.unixTimestamp, r.offsetSeconds), metrics.valueFontSize, isDarkMode ? Colors.white70 : Colors.black87);
            final tpE = _getTextPainter(_formatUnix(endUnix, r.offsetSeconds), metrics.valueFontSize, isDarkMode ? Colors.white70 : Colors.black87);
            bool barFitsLabels = (endY - startY) > (tpS.width + tpE.width + 20);

            if (r.unixTimestamp >= dayStartUnix) {
              double proposedY = barFitsLabels ? startY + (metrics.valueFontSize * 0.9) : startY - 5;
              bool proposedAbove = !barFitsLabels;
              math.Rectangle rect = math.Rectangle(centerX - tpS.height/2, proposedAbove ? proposedY - tpS.width : proposedY, tpS.height, tpS.width);
              bool collision = false;
              for (var area in occupiedAreas) {
                if (rect.intersects(area)) { collision = true; break; }
              }
              if (proposedAbove && (proposedY - tpS.width < metrics.topPadding || collision)) { proposedY = startY + (metrics.valueFontSize * 0.9); proposedAbove = false; }
              _drawVerticalTextWithPainter(canvas, tpS, Offset(centerX, proposedY), isAbove: proposedAbove);
              occupiedAreas.add(math.Rectangle(centerX - tpS.height/2, proposedAbove ? proposedY - tpS.width : proposedY, tpS.height, tpS.width));
            }

            if (sLocalEnd <= dayStartUnix + 86400) {
              double proposedY = barFitsLabels ? endY - (metrics.valueFontSize * 0.9) : endY + 5;
              bool proposedAbove = barFitsLabels;
              math.Rectangle rect = math.Rectangle(centerX - tpE.height/2, proposedAbove ? proposedY - tpE.width : proposedY, tpE.height, tpE.width);
              bool collision = false;
              for (var area in occupiedAreas) {
                if (rect.intersects(area)) { collision = true; break; }
              }
              if (!proposedAbove && (proposedY + tpE.width > (metrics.topPadding + chartHeight) || collision)) { proposedY = endY - (metrics.valueFontSize * 0.9); proposedAbove = true; }
              _drawVerticalTextWithPainter(canvas, tpE, Offset(centerX, proposedY), isAbove: proposedAbove);
              occupiedAreas.add(math.Rectangle(centerX - tpE.height/2, proposedAbove ? proposedY - tpE.width : proposedY, tpE.height, tpE.width));
            }
          }
        }
      }

      final customPaints = dayRecords.where((r) => r.typeId != sleepType.id).toList();

      for (var r in customPaints) {
        final type = types.firstWhere((t) => t.id == r.typeId, orElse: () => types[0]);
        final typeColor = Color(type.colorValue ?? 0xFF3F51B5);
        final medPaint = Paint()..color = typeColor..style = PaintingStyle.fill;

        final double fractionalDay = (r.unixTimestamp - dayStartUnix) / 86400.0;
        final double medY = metrics.topPadding + fractionalDay * chartHeight;

        canvas.drawCircle(Offset(centerX, medY), metrics.medRadius, medPaint);
        occupiedAreas.add(math.Rectangle(centerX - metrics.medRadius, medY - metrics.medRadius, metrics.medRadius * 2, metrics.medRadius * 2));

        if (showAllDetails) {
          final dt = DateTime.fromMillisecondsSinceEpoch((r.unixTimestamp + r.offsetSeconds) * 1000, isUtc: true);
          final timeStr = DateFormat('HH:mm').format(dt);
          
          String txt = timeStr;
          if (r.value != null && r.value!.trim().isNotEmpty) {
            txt = "${type.name}: ${r.value}";
          }
          
          final tp = _getTextPainter(txt, metrics.valueFontSize * 0.95, typeColor.withOpacity(0.9), isBold: r.value != null);
          
          bool isAbove = true;
          double textY = medY - metrics.medRadius - 5;
          if (textY - tp.width < metrics.topPadding) { 
            isAbove = false; 
            textY = medY + metrics.medRadius + 5; 
          }
          
          _drawVerticalTextWithPainter(canvas, tp, Offset(centerX, textY), isAbove: isAbove);
          occupiedAreas.add(math.Rectangle(centerX - tp.height/2, isAbove ? textY - tp.width : textY, tp.height, tp.width));
        }
      }
    }
  }

  TextPainter _getTextPainter(String text, double fontSize, Color color, {bool isBold = false}) {
    return TextPainter(text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), textDirection: ui.TextDirection.ltr)..layout();
  }

  void _drawTextWithPainter(Canvas canvas, TextPainter tp, Offset offset) => tp.paint(canvas, offset);

  void _drawVerticalTextWithPainter(Canvas canvas, TextPainter tp, Offset pos, {required bool isAbove}) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(math.pi / 2);
    tp.paint(canvas, Offset(isAbove ? -tp.width : 0, -tp.height / 2));
    canvas.restore();
  }

  String _formatUnix(int? unix, int offset) {
    if (unix == null) return "--:--";
    final dt = DateTime.fromMillisecondsSinceEpoch((unix + offset) * 1000, isUtc: true);
    return DateFormat('HH:mm').format(dt);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
