import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import 'package:drift/drift.dart' show Value;
import '../../database/database.dart';

// 터치 판정 및 삭제를 위한 데이터 구조
class _HitInfo {
  final String id;
  final String hitType;
  final String timeText;
  final Offset targetPos;
  final String displayDate;

  _HitInfo({
    required this.id,
    required this.hitType,
    required this.timeText,
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

  Future<void> _savePeriod(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('statistics_period', days);
    if (mounted) {
      setState(() {
        _selectedPeriodDays = days;
        _currentPageIndex = 0;
        _pageController.jumpToPage(0);
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

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final DateTime baseDate = DateTime(today.year, today.month, today.day);
    
    final daysOffset = _currentPageIndex * _selectedPeriodDays;
    final displayEndDate = baseDate.subtract(Duration(days: daysOffset));
    final displayStartDate = displayEndDate.subtract(Duration(days: _selectedPeriodDays - 1));

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 8),
                _buildAnimatedHeader(displayStartDate, displayEndDate),
                const SizedBox(height: 12),
                _buildLegend(),
                const SizedBox(height: 10),
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
                        yAxisWidth: yAxisWidth,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isMenuOpen)
            GestureDetector(
              onTap: () => setState(() => _isMenuOpen = false),
              child: Container(color: Colors.black.withValues(alpha: 0.1)),
            ),
          _buildFabMenu(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [7, 14, 30].map((days) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text("$days일"),
                selected: _selectedPeriodDays == days,
                onSelected: (selected) {
                  if (selected) _savePeriod(days);
                },
              ),
            );
          }).toList(),
        ),
        Row(
          children: [
            IconButton(
              onPressed: _resetToToday,
              icon: const Icon(Icons.today_outlined),
              tooltip: "오늘로 이동",
            ),
            IconButton(
              onPressed: () => setState(() => _showAllDetails = !_showAllDetails),
              icon: Icon(
                _showAllDetails ? Icons.segment : Icons.segment_outlined,
                color: _showAllDetails ? Colors.indigo : null,
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => setState(() => _isMenuOpen = !_isMenuOpen),
              icon: Icon(_isMenuOpen ? Icons.close : Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedHeader(DateTime start, DateTime end) {
    final f = DateFormat('yyyy.MM.dd');
    final isTodayPage = _currentPageIndex == 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => _movePage(1),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey<int>(_currentPageIndex), 
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              "${f.format(start)} ~ ${f.format(end)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 15, 
                color: Colors.indigo,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 28),
          onPressed: isTodayPage ? null : () => _movePage(-1),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(children: [
      _legendItem(Colors.green.withValues(alpha: 0.7), "수면 구간"), const SizedBox(width: 12),
      _legendItem(Colors.indigo, "약 복용"),
    ]);
  }

  Widget _legendItem(Color c, String l) => Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)), const SizedBox(width: 4), Text(l, style: const TextStyle(fontSize: 11))]);

  Widget _buildFabMenu() {
    if (!_isMenuOpen) return const SizedBox.shrink();
    return Positioned(top: 80, right: 16, child: Material(elevation: 8, borderRadius: BorderRadius.circular(12), child: Column(mainAxisSize: MainAxisSize.min, children: [
      _menuItem(Icons.medication, "복용 기록 추가", _pickMedicationTime), const Divider(height: 1),
      _menuItem(Icons.bedtime, "수면 기록 추가", _pickSleepPeriod),
    ])));
  }

  Widget _menuItem(IconData i, String l, VoidCallback t) => InkWell(onTap: () { setState(() => _isMenuOpen = false); t(); }, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [Icon(i, size: 20, color: Colors.indigo), const SizedBox(width: 12), Text(l)])));

  Future<void> _pickMedicationTime() async {
    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
    if (d == null) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t == null) return;
    await widget.database.logMedicationIntake(dateTime: DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> _pickSleepPeriod() async {
    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
    if (d == null) return;
    final sT = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 22, minute: 0), helpText: "수면 시작");
    if (sT == null) return;
    final eT = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 7, minute: 0), helpText: "기상 시각");
    if (eT == null) return;
    final start = DateTime(d.year, d.month, d.day, sT.hour, sT.minute);
    var end = DateTime(d.year, d.month, d.day, eT.hour, eT.minute);
    if (end.isBefore(start)) end = end.add(const Duration(days: 1));
    await widget.database.addSleepSession(date: DateFormat('yyyy-MM-dd').format(d), start: start, end: end);
  }

  void _executeLongPress(_HitInfo hit) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(hit.hitType == 'med' ? "약 기록 삭제" : "수면 세션 삭제"), content: const Text("정말로 삭제하시겠습니까?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
        TextButton(onPressed: () async {
          if (hit.hitType == 'med') await widget.database.deleteMedicationIntake(hit.displayDate, hit.id);
          else await widget.database.deleteSession(int.parse(hit.id));
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
      widget.database.watchSessionsInPeriod(startOfWindow, endOfWindow),
      (List<DailySleepRecord> records, List<SleepSession> sessions) => {'records': records, 'sessions': sessions},
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
        final List<DailySleepRecord> records = snapshot.hasData ? List<DailySleepRecord>.from(snapshot.data!['records'] as Iterable) : <DailySleepRecord>[];
        final List<SleepSession> sessions = snapshot.hasData ? List<SleepSession>.from(snapshot.data!['sessions'] as Iterable) : <SleepSession>[];

        return LayoutBuilder(
          builder: (context, constraints) {
            final double dayWidth = (constraints.maxWidth - widget.yAxisWidth) / pageDates.length;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                final hit = _checkHit(details.localPosition, pageDates, records, sessions, dayWidth, widget.yAxisWidth, constraints.maxHeight);
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
                  sessions: sessions,
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

  _HitInfo? _checkHit(Offset pos, List<DateTime> dates, List<DailySleepRecord> records, List<SleepSession> sessions, double dayWidth, double left, double height) {
    const double topPadding = 60.0;
    const double bottomPadding = 30.0;
    final double chartHeight = height - topPadding - bottomPadding;
    final double x = pos.dx - left;
    if (x < 0) return null;
    final int dayIdx = (x / dayWidth).floor();
    if (dayIdx < 0 || dayIdx >= dates.length) return null;
    final dateStr = DateFormat('yyyy-MM-dd').format(dates[dayIdx]);
    final double centerX = left + (dayIdx * dayWidth) + (dayWidth / 2);
    final double barW = (dayWidth * 0.85).clamp(10.0, 80.0);

    // 1. 약 복용 점 체크
    final rec = records.where((r) => r.date == dateStr).firstOrNull;
    if (rec?.medications != null) {
      for (var med in rec!.medications!) {
        final unix = med['unix'] as int?;
        final offset = med['offset'] as int?;
        if (unix != null && offset != null) {
          final dt = DateTime.fromMillisecondsSinceEpoch((unix + offset) * 1000, isUtc: true);
          final y = topPadding + (((dt.hour + dt.minute / 60.0) / 24.0) * chartHeight);
          if ((pos - Offset(centerX, y)).distance <= (barW * 0.6).clamp(15.0, 35.0)) return _HitInfo(id: unix.toString(), hitType: 'med', timeText: med['time'] as String, targetPos: Offset(centerX, y), displayDate: rec.date);
        }
      }
    }

    // 2. 수면 세션 체크 (실제 막대 영역만 판정)
    final dayStartUnix = dates[dayIdx].millisecondsSinceEpoch ~/ 1000;
    final dayLocalStart = dayStartUnix + DateTime.fromMillisecondsSinceEpoch(dayStartUnix * 1000).timeZoneOffset.inSeconds;
    for (var s in sessions) {
      final sLocalStart = s.startUnix + s.offsetSeconds;
      final sLocalEnd = (s.endUnix ?? s.startUnix) + s.offsetSeconds;
      final drawStart = math.max(sLocalStart, dayLocalStart);
      final drawEnd = math.min(sLocalEnd, dayLocalStart + 86400);
      if (drawStart < drawEnd) {
        final double startY = topPadding + ((drawStart - dayLocalStart) / 86400.0) * chartHeight;
        final double endY = topPadding + ((drawEnd - dayLocalStart) / 86400.0) * chartHeight;
        if (pos.dx >= centerX - barW/2 && pos.dx <= centerX + barW/2 && pos.dy >= startY && pos.dy <= endY) {
          final dtS = DateTime.fromMillisecondsSinceEpoch(sLocalStart * 1000, isUtc: true);
          final dtE = DateTime.fromMillisecondsSinceEpoch(sLocalEnd * 1000, isUtc: true);
          return _HitInfo(id: s.id.toString(), hitType: 'sleep', timeText: "${DateFormat('HH:mm').format(dtS)} ~ ${DateFormat('HH:mm').format(dtE)}", targetPos: Offset(centerX, pos.dy), displayDate: s.date);
        }
      }
    }
    return null;
  }
}

class SleepTimelinePainter extends CustomPainter {
  final List<DateTime> allDates;
  final List<DailySleepRecord> records;
  final List<SleepSession> sessions;
  final bool isDarkMode;
  final double dayWidth;
  final bool showAllDetails;
  final double yAxisWidth;

  SleepTimelinePainter({required this.allDates, required this.records, required this.sessions, required this.isDarkMode, required this.dayWidth, required this.showAllDetails, required this.yAxisWidth});

  @override
  void paint(Canvas canvas, Size size) {
    const double topPadding = 60.0;
    const double bottomPadding = 30.0;
    final double chartHeight = size.height - topPadding - bottomPadding;

    final gridPaint = Paint()..color = isDarkMode ? Colors.white12 : Colors.black12..strokeWidth = 1;
    final sleepPaint = Paint()..color = Colors.green.withValues(alpha: 0.7)..style = PaintingStyle.fill;
    final medPaint = Paint()..color = Colors.indigo..style = PaintingStyle.fill;

    final double barWidth = (dayWidth * 0.85).clamp(10.0, 80.0);
    final double labelFontSize = (barWidth * 0.35).clamp(11.0, 20.0);
    final double dateFontSize = (barWidth * 0.6).clamp(13.0, 36.0);
    final double valueFontSize = (barWidth * 0.45).clamp(10.0, 24.0);

    for (int h = 0; h <= 24; h += 6) {
      double y = topPadding + (h / 24.0) * chartHeight;
      canvas.drawLine(Offset(yAxisWidth, y), Offset(size.width, y), gridPaint);
      final tpYLabel = _getTextPainter("${h.toString().padLeft(2, '0')}:00", labelFontSize, Colors.grey);
      canvas.save();
      canvas.translate(yAxisWidth / 2, y);
      canvas.rotate(math.pi / 2);
      tpYLabel.paint(canvas, Offset(-tpYLabel.width / 2, -tpYLabel.height / 2));
      canvas.restore();
    }

    for (int i = 0; i < allDates.length; i++) {
      final date = allDates[i];
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final double centerX = yAxisWidth + (i * dayWidth) + (dayWidth / 2);

      final tpLabel = _getTextPainter(DateFormat('E', 'ko_KR').format(date), labelFontSize, Colors.grey);
      _drawTextWithPainter(canvas, tpLabel, Offset(centerX - tpLabel.width / 2, 5));
      final tpDate = _getTextPainter(DateFormat('dd').format(date), dateFontSize, isDarkMode ? Colors.white : Colors.black, isBold: true);
      _drawTextWithPainter(canvas, tpDate, Offset(centerX - tpDate.width / 2, 5 + labelFontSize + 4));

      canvas.drawLine(Offset(centerX, topPadding), Offset(centerX, topPadding + chartHeight), gridPaint);

      final dayStartUnix = date.millisecondsSinceEpoch ~/ 1000;
      final dayLocalStart = dayStartUnix + DateTime.fromMillisecondsSinceEpoch(dayStartUnix * 1000).timeZoneOffset.inSeconds;
      final List<math.Rectangle<double>> occupiedAreas = [];

      final record = records.where((r) => r.date == dateStr).firstOrNull;
      if (record?.medications != null) {
        for (var med in record!.medications!) {
          final int? unix = med['unix'] as int?;
          final int? offset = med['offset'] as int?;
          if (unix != null && offset != null) {
            final dt = DateTime.fromMillisecondsSinceEpoch((unix + offset) * 1000, isUtc: true);
            double medY = topPadding + ((dt.hour + dt.minute / 60.0) / 24.0) * chartHeight;
            double r = barWidth / 2;
            
            canvas.drawCircle(Offset(centerX, medY), r, Paint()..color = isDarkMode ? Colors.black : Colors.white);
            canvas.drawCircle(Offset(centerX, medY), r - 1.5, medPaint);
            occupiedAreas.add(math.Rectangle(centerX - r, medY - r, barWidth, r * 2));
            if (showAllDetails) {
              final tp = _getTextPainter(med['time'] as String, valueFontSize, Colors.indigoAccent, isVertical: true);
              bool isAbove = true;
              double textY = medY - r - 5;
              if (textY - tp.width < topPadding) { isAbove = false; textY = medY + r + 5; }
              _drawVerticalTextWithPainter(canvas, tp, Offset(centerX, textY), isAbove: isAbove);
              occupiedAreas.add(math.Rectangle(centerX - tp.height/2, isAbove ? textY - tp.width : textY, tp.height, tp.width));
            }
          }
        }
      }

      for (var s in sessions) {
        final sLocalStart = s.startUnix + s.offsetSeconds;
        final sLocalEnd = (s.endUnix ?? s.startUnix) + s.offsetSeconds;
        final drawStart = math.max(sLocalStart, dayLocalStart);
        final drawEnd = math.min(sLocalEnd, dayLocalStart + 86400);

        if (drawStart < drawEnd) {
          final double startY = topPadding + ((drawStart - dayLocalStart) / 86400.0) * chartHeight;
          final double endY = topPadding + ((drawEnd - dayLocalStart) / 86400.0) * chartHeight;
          final double cornerRadius = barWidth / 2;

          canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromLTRB(centerX - barWidth/2, startY, centerX + barWidth/2, endY), topLeft: sLocalStart >= dayLocalStart ? Radius.circular(cornerRadius) : Radius.zero, topRight: sLocalStart >= dayLocalStart ? Radius.circular(cornerRadius) : Radius.zero, bottomLeft: sLocalEnd <= dayLocalStart + 86400 ? Radius.circular(cornerRadius) : Radius.zero, bottomRight: sLocalEnd <= dayLocalStart + 86400 ? Radius.circular(cornerRadius) : Radius.zero), sleepPaint);

          if (showAllDetails) {
            final tpS = _getTextPainter(_formatUnix(s.startUnix, s.offsetSeconds), valueFontSize, isDarkMode ? Colors.white70 : Colors.black87, isVertical: true);
            final tpE = _getTextPainter(_formatUnix(s.endUnix, s.offsetSeconds), valueFontSize, isDarkMode ? Colors.white70 : Colors.black87, isVertical: true);
            bool barFitsLabels = (endY - startY) > (tpS.width + tpE.width + 20);

            if (sLocalStart >= dayLocalStart) {
              double proposedY = barFitsLabels ? startY + (valueFontSize * 0.9) : startY - 5;
              bool proposedAbove = !barFitsLabels;
              math.Rectangle rect = math.Rectangle(centerX - tpS.height/2, proposedAbove ? proposedY - tpS.width : proposedY, tpS.height, tpS.width);
              bool collision = false;
              for (var area in occupiedAreas) if (rect.intersects(area)) { collision = true; break; }
              if (proposedAbove && (proposedY - tpS.width < topPadding || collision)) { proposedY = startY + (valueFontSize * 0.9); proposedAbove = false; }
              _drawVerticalTextWithPainter(canvas, tpS, Offset(centerX, proposedY), isAbove: proposedAbove);
              occupiedAreas.add(math.Rectangle(centerX - tpS.height/2, proposedAbove ? proposedY - tpS.width : proposedY, tpS.height, tpS.width));
            }

            if (sLocalEnd <= dayLocalStart + 86400) {
              double proposedY = barFitsLabels ? endY - (valueFontSize * 0.9) : endY + 5;
              bool proposedAbove = barFitsLabels;
              math.Rectangle rect = math.Rectangle(centerX - tpE.height/2, proposedAbove ? proposedY - tpE.width : proposedY, tpE.height, tpE.width);
              bool collision = false;
              for (var area in occupiedAreas) if (rect.intersects(area)) { collision = true; break; }
              if (!proposedAbove && (proposedY + tpE.width > (topPadding + chartHeight) || collision)) { proposedY = endY - (valueFontSize * 0.9); proposedAbove = true; }
              _drawVerticalTextWithPainter(canvas, tpE, Offset(centerX, proposedY), isAbove: proposedAbove);
              occupiedAreas.add(math.Rectangle(centerX - tpE.height/2, proposedAbove ? proposedY - tpE.width : proposedY, tpE.height, tpE.width));
            }
          }
        }
      }
    }
  }

  TextPainter _getTextPainter(String text, double fontSize, Color color, {bool isBold = false, bool isVertical = false}) {
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

  void _drawText(Canvas canvas, String text, Offset offset, double fontSize, Color color, {bool isBold = false}) {
    final tp = _getTextPainter(text, fontSize, color, isBold: isBold);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
