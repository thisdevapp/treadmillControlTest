import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import '../../database/database.dart';
import '../widgets/custom_picker_utils.dart';
import '../widgets/record_manager.dart';
import '../widgets/record_type_manager.dart';

/// 차트 상단 날짜 표기 방식 (설정 > 편의성 기능 > 차트 보기 > 날짜 표기)
enum ChartDateLabelMode {
  /// 좌우 공간에 따라 45도 / 90도 자동 선택
  dynamic,
  /// 요일 위, 날짜 아래로 가로 표기
  horizontal,
  /// 항상 90도로 세워서 표기
  vertical;

  String get label => switch (this) {
    ChartDateLabelMode.dynamic => "동적",
    ChartDateLabelMode.horizontal => "가로",
    ChartDateLabelMode.vertical => "세로",
  };

  String get description => switch (this) {
    ChartDateLabelMode.dynamic => "공간이 넉넉하면 45도, 부족하면 90도로 세워서 표기",
    ChartDateLabelMode.horizontal => "요일 아래에 날짜를 가로로 표기",
    ChartDateLabelMode.vertical => "항상 90도로 세워서 표기",
  };
}

/// 모든 차트 요소의 크기와 패딩을 중앙 관리하는 클래스
class _ChartMetrics {
  final double barWidth;
  final double medRadius;
  final double labelFontSize;
  final double dateFontSize;
  final double valueFontSize;
  final double topPadding;
  /// 상단 날짜 라벨 회전 각도 (시계방향, 0이면 요일/날짜 두 줄 가로 표기)
  final double headerAngle;

  /// 상단 날짜 라벨과 차트 사이 간격
  static const double headerGap = 6.0;
  /// 이웃한 날짜 라벨 사이에 최소한 확보할 여백
  static const double headerSpacing = 2.0;
  /// 가로 표기 시 날짜를 요일 쪽으로 끌어올리는 양
  static const double stackedOverlap = 4.0;
  static final Map<double, (Size, double)> _headerSizeCache = {};

  factory _ChartMetrics(double dayWidth, ChartDateLabelMode mode) {
    double bw = (dayWidth * 0.75).clamp(6.0, 150.0);
    bw = (bw * 2).roundToDouble() / 2.0;

    final double lfs = (bw * 0.25 + 6).clamp(8.0, 30.0);
    final double dfs = (bw * 0.5 + 7).clamp(10.0, 60.0);
    final double vfs = (bw * 0.3 + 4).clamp(7.0, 32.0);

    // 글꼴 크기는 bw로만 정해지므로 라벨 크기는 bw 단위로 캐시
    // (한 줄 라벨 크기, 두 줄 가로 표기 높이)
    final (Size header, double stackedHeight) = _headerSizeCache.putIfAbsent(bw, () {
      final tp = headerPainter("월", "00", lfs, dfs, Colors.grey);
      final tpLabel = stackedLabelPainter("월", lfs);
      final tpDate = stackedDatePainter("00", dfs, Colors.grey);
      return (tp.size, tpLabel.height - stackedOverlap + tpDate.height);
    });

    final double angle;
    final double headerHeight;
    if (mode == ChartDateLabelMode.horizontal) {
      angle = 0;
      headerHeight = stackedHeight;
    } else {
      // 좌우 공간 체크: 45도로 기울이면 이웃 라벨과의 수직 간격이 dayWidth * sin45로 줄어듦.
      // 이 간격이 라벨 높이보다 좁으면 겹치므로 90도로 세워서 dayWidth 전체를 사용
      final bool fitsDiagonal = dayWidth * math.sin(math.pi / 4) >= header.height + headerSpacing;
      angle = mode == ChartDateLabelMode.dynamic && fitsDiagonal ? math.pi / 4 : math.pi / 2;
      // 회전된 라벨이 차지하는 세로 높이 = 너비 * sinθ + 높이 * cosθ
      headerHeight = header.width * math.sin(angle) + header.height * math.cos(angle);
    }

    return _ChartMetrics._(
      barWidth: bw,
      medRadius: bw / 2.0,
      labelFontSize: lfs,
      dateFontSize: dfs,
      valueFontSize: vfs,
      topPadding: (headerHeight + headerGap + 2).clamp(20.0, 150.0),
      headerAngle: angle,
    );
  }

  /// 상단 날짜 라벨 (요일 + 날짜를 한 줄로)
  static TextPainter headerPainter(String weekday, String day, double lfs, double dfs, Color dateColor) {
    return TextPainter(
      text: TextSpan(children: [
        TextSpan(text: weekday, style: TextStyle(color: Colors.grey, fontSize: lfs)),
        TextSpan(text: " $day", style: TextStyle(color: dateColor, fontSize: dfs, fontWeight: FontWeight.bold)),
      ]),
      textDirection: ui.TextDirection.ltr,
    )..layout();
  }

  /// 가로 표기용 요일 (윗줄)
  static TextPainter stackedLabelPainter(String weekday, double lfs) {
    return TextPainter(
      text: TextSpan(text: weekday, style: TextStyle(color: Colors.grey, fontSize: lfs)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
  }

  /// 가로 표기용 날짜 (아랫줄)
  static TextPainter stackedDatePainter(String day, double dfs, Color dateColor) {
    return TextPainter(
      text: TextSpan(text: day, style: TextStyle(color: dateColor, fontSize: dfs, fontWeight: FontWeight.bold)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
  }

  _ChartMetrics._({
    required this.barWidth,
    required this.medRadius,
    required this.labelFontSize,
    required this.dateFontSize,
    required this.valueFontSize,
    required this.topPadding,
    required this.headerAngle,
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

/// 차트 페이지 클립: 상단 날짜 라벨 구간은 전체 너비, 그 아래 차트 구간은 Y축 영역을 제외
class _ChartPageClipper extends CustomClipper<Path> {
  final double left;
  final double top;

  _ChartPageClipper({required this.left, required this.top});

  @override
  Path getClip(Size size) => Path()
    ..addRect(Rect.fromLTRB(0, 0, size.width, top))
    ..addRect(Rect.fromLTRB(left, top, size.width, size.height));

  @override
  bool shouldReclip(covariant _ChartPageClipper oldClipper) => oldClipper.left != left || oldClipper.top != top;
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
  final bool showAllDetails;
  final Function(bool) onShowAllDetailsChanged;
  final ChartDateLabelMode dateLabelMode;

  const StatisticsScreen({
    super.key,
    required this.database,
    required this.longPressSeconds,
    required this.showAllDetails,
    required this.onShowAllDetailsChanged,
    required this.dateLabelMode,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedPeriodDays = 7;
  late PageController _pageController;
  int _currentPageIndex = 0; 
  bool _isMenuOpen = false;
  bool _isChartDrafting = false; // 차트에서 점/라인 생성 중에는 페이지 스와이프 잠금

  final LayerLink _layerLink = LayerLink(); // 버튼과 메뉴를 연결할 레이어 링크

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
                    final metrics = _ChartMetrics(dayWidth, widget.dateLabelMode);

                    // 페이지는 Y축 영역까지 포함한 전체 너비로 그리고, Y축 영역은 상단 날짜 라벨 구간만 보이도록 잘라냄
                    // (첫 날짜의 기울어진 라벨이 왼쪽으로 잘리지 않도록)
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: ClipPath(
                            clipper: _ChartPageClipper(left: yAxisWidth, top: metrics.topPadding - 1),
                            child: PageView.builder(
                            controller: _pageController,
                            reverse: true, 
                            physics: _isChartDrafting
                                ? const NeverScrollableScrollPhysics()
                                : const BouncingScrollPhysics(),
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
                                showAllDetails: widget.showAllDetails,
                                longPressSeconds: widget.longPressSeconds,
                                onExecuteLongPress: _executeLongPress,
                                onDraftingChanged: (drafting) {
                                  if (mounted && _isChartDrafting != drafting) {
                                    setState(() => _isChartDrafting = drafting);
                                  }
                                },
                                yAxisWidth: yAxisWidth,
                                dateLabelMode: widget.dateLabelMode,
                              );
                            },
                          ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: yAxisWidth,
                          child: CustomPaint(
                            painter: _StaticYAxisPainter(
                              metrics: metrics,
                              isDarkMode: Theme.of(context).brightness == Brightness.dark,
                            ),
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
              child: Container(color: Colors.black.withValues(alpha: 0.1)),
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
                onPressed: () => widget.onShowAllDetailsChanged(!widget.showAllDetails),
                icon: Icon(
                  widget.showAllDetails ? Icons.segment : Icons.segment_outlined,
                  color: widget.showAllDetails ? Colors.indigo : null,
                  size: 18,
                ),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              CompositedTransformTarget(
                link: _layerLink,
                child: IconButton.filledTonal(
                  onPressed: () {
                    setState(() => _isMenuOpen = !_isMenuOpen);
                  },
                  icon: Icon(_isMenuOpen ? Icons.close : Icons.add, size: 18),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
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
              color: Colors.indigo.withValues(alpha: 0.08),
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
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.8), shape: BoxShape.circle),
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

    return CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      offset: const Offset(-140, 36), // 버튼 위치 기준 (좌측으로 140px 이동, 아래로 36px 이동)
      child: Material(
        elevation: 8,
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 180,
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
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String? name) {
    return RecordManager.getIconData(name);
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
          // 박스나 배경 없이 아이콘만 렌더링
          Icon(i, size: 24, color: Colors.indigo), 
          const SizedBox(width: 12), 
          Text(l, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );

  Future<void> _pickCustomEventTime(CustomDataType type) async {
    await RecordManager.showAddPastRecordDialog(
      context: context,
      database: widget.database,
      type: type,
      onShowToast: (t, msg) => RecordManager.showRecordToast(context, t, msg),
    );
  }

  Future<void> _pickSleepPeriod(int sleepTypeId) async {
    await RecordManager.showSleepLogDialog(
      context: context,
      database: widget.database,
      sleepTypeId: sleepTypeId,
      onShowToast: (t, msg) => RecordManager.showRecordToast(context, t, msg),
    );
  }

  void _executeLongPress(_HitInfo hit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(hit.titleText, style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.close_rounded, color: Colors.grey),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch, // 버튼이 가로로 꽉 차도록 설정
          children: [
            Text(hit.subtitleText, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            const Text("수행할 동작을 선택하세요", 
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)
            ),
            const SizedBox(height: 16),
            
            // 수정 버튼 (한 라인 차지)
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _editRecord(hit);
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.edit_rounded),
              label: const Text("기록 수정하기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            
            const SizedBox(height: 12),
            
            // 삭제 버튼 (한 라인 차지)
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _confirmDelete(hit);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              label: const Text("기록 삭제하기", style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: const [],
      ),
    );
  }

  Future<void> _editRecord(_HitInfo hit) async {
    // DB에서 최신 데이터 가져오기 (문법 수정: widget.database.select 사용)
    final r = await (widget.database.select(widget.database.customDataRecords)
          ..where((t) => t.id.equals(hit.recordId)))
        .getSingle();

    final types = await widget.database.getCustomDataTypes();
    final type = types.firstWhere((t) => t.id == r.typeId);

    if (!mounted) return;

    if (hit.hitType == 'sleep') {
      int? endUnix;
      String? memo;
      try {
        final decoded = json.decode(r.value!);
        endUnix = decoded['endUnix'] as int?;
        memo = decoded['memo'] as String?;
      } catch (_) {}

      RecordManager.showSleepLogDialog(
        context: context,
        database: widget.database,
        sleepTypeId: r.typeId,
        onShowToast: (t, msg) => RecordManager.showRecordToast(context, t, msg),
        existingRecordId: r.id,
        initialStart: DateTime.fromMillisecondsSinceEpoch(r.unixTimestamp * 1000),
        initialEnd: endUnix != null ? DateTime.fromMillisecondsSinceEpoch(endUnix * 1000) : null,
        initialMemo: memo,
      );
    } else {
      // 일반 기록 수정 (시간만 수정하는 팝업 호출)
      RecordManager.showAddPastRecordDialog(
        context: context,
        database: widget.database,
        type: type,
        onShowToast: (t, msg) => RecordManager.showRecordToast(context, t, msg),
        existingRecordId: r.id,
        initialTimestamp: DateTime.fromMillisecondsSinceEpoch(r.unixTimestamp * 1000),
        initialValue: r.value,
      );
    }
  }

  void _confirmDelete(_HitInfo hit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("기록 삭제"),
        content: const Text("정말로 이 기록을 완전히 삭제하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
          TextButton(
            onPressed: () async {
              await widget.database.deleteCustomDataRecord(hit.recordId);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("삭제", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
  final Function(bool) onDraftingChanged;
  final ChartDateLabelMode dateLabelMode;

  const _StatisticsPageContent({
    required this.dateLabelMode,
    required this.database,
    required this.pageIndex,
    required this.periodDays,
    required this.showAllDetails,
    required this.longPressSeconds,
    required this.yAxisWidth,
    required this.onExecuteLongPress,
    required this.onDraftingChanged,
  });

  @override
  State<_StatisticsPageContent> createState() => _StatisticsPageContentState();
}

/// 차트 위 한 지점 (날짜 칸 + 하루 중 분, 5분 단위 스냅)
class _DraftAnchor {
  final int dayIdx;
  final int minutes;

  const _DraftAnchor(this.dayIdx, this.minutes);

  int compareTo(_DraftAnchor other) =>
      dayIdx != other.dayIdx ? dayIdx.compareTo(other.dayIdx) : minutes.compareTo(other.minutes);

  @override
  bool operator ==(Object other) => other is _DraftAnchor && other.dayIdx == dayIdx && other.minutes == minutes;

  @override
  int get hashCode => Object.hash(dayIdx, minutes);
}

/// 현재 페이지의 차트 레이아웃/데이터 스냅샷 (포인터 이벤트 처리용)
class _ChartFrame {
  final List<DateTime> dates;
  final List<CustomDataRecord> records;
  final List<CustomDataType> types;
  final double dayWidth;
  final double height;

  _ChartFrame({
    required this.dates,
    required this.records,
    required this.types,
    required this.dayWidth,
    required this.height,
  });
}

/// 물방울 이펙트용 점 (머리는 목표 위치를 빠르게, 꼬리는 머리를 느리게 따라감)
class _Drop {
  Offset head;
  Offset tail;
  double age = 0; // 생성 후 경과 시간(초), 톡 튀어나오는 크기 애니메이션에 사용
  double grow = _Drop.touchGrow; // 크기 배율: 손가락이 닿아 있는 동안 커져서 가려지지 않도록 함

  static const double touchGrow = 2.0;

  _Drop(Offset pos) : head = pos, tail = pos;
}

class _StatisticsPageContentState extends State<_StatisticsPageContent> with SingleTickerProviderStateMixin {
  Stream<Map<String, dynamic>>? _pageStream;
  Timer? _longPressTimer;
  Offset? _tapDownPos;
  static const double _dragSlop = 20.0; // 드래그 무시 범위 (픽셀)

  // 빈 칸 꾹 누르기 → 점/라인 생성
  static const double _createSlop = 10.0; // PageView 스와이프(18px)보다 먼저 취소되도록 작게 설정
  static const int _snapMinutes = 5;
  Timer? _createTimer;
  _ChartFrame? _frame;
  int? _primaryPointer;
  int? _secondaryPointer;
  Offset? _lastPrimaryPos;
  Offset? _secondaryPos; // 생성 중 두 번째 손가락 위치 (말풍선 위치 계산용)
  _DraftAnchor? _draftStart; // 첫 번째 손가락 (점)
  _DraftAnchor? _draftEnd; // 두 번째 손가락 (라인으로 전환 시)
  _Drop? _startDrop;
  _Drop? _endDrop;
  late final Ticker _dropTicker;
  Duration _lastDropTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _dropTicker = createTicker(_onDropTick);
    _initStream();
  }

  @override
  void didUpdateWidget(_StatisticsPageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageIndex != widget.pageIndex || oldWidget.periodDays != widget.periodDays) {
      _initStream();
    }
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _createTimer?.cancel();
    _dropTicker.dispose();
    if (_draftStart != null) {
      // dispose 중에는 부모 setState가 불가하므로 다음 프레임에 잠금 해제
      final onDraftingChanged = widget.onDraftingChanged;
      WidgetsBinding.instance.addPostFrameCallback((_) => onDraftingChanged(false));
    }
    super.dispose();
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
            final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
            _frame = _ChartFrame(
              dates: pageDates,
              records: records,
              types: types,
              dayWidth: dayWidth,
              height: constraints.maxHeight,
            );

            // GestureDetector 대신 Listener를 사용하여 멀티 터치(두 번째 손가락)를 직접 추적
            return Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _handlePointerDown,
              onPointerMove: _handlePointerMove,
              onPointerUp: _handlePointerEnd,
              onPointerCancel: _handlePointerEnd,
              child: CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: SleepTimelinePainter(
                  allDates: pageDates,
                  records: records,
                  types: types,
                  isDarkMode: isDarkMode,
                  dayWidth: dayWidth,
                  showAllDetails: widget.showAllDetails,
                  yAxisWidth: widget.yAxisWidth,
                  dateLabelMode: widget.dateLabelMode,
                ),
                foregroundPainter: _draftStart == null || _startDrop == null ? null : _DraftPainter(
                  dates: pageDates,
                  dayWidth: dayWidth,
                  dateLabelMode: widget.dateLabelMode,
                  left: widget.yAxisWidth,
                  start: _draftStart!,
                  end: _draftEnd,
                  startDrop: _startDrop!,
                  endDrop: _endDrop,
                  color: _draftEnd != null
                      ? Color(RecordManager.findSleepType(types)?.colorValue ?? 0xFF4CAF50)
                      : Theme.of(context).colorScheme.primary,
                  isDarkMode: isDarkMode,
                  touches: [?_lastPrimaryPos, ?_secondaryPos],
                  label: _draftLabel(pageDates),
                  hint: _draftEnd == null ? "옆에 손가락을 하나 더 대면 기간으로 전환" : null,
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // 포인터 처리: 기존 기록 꾹 누르기(수정/삭제) + 빈 칸 꾹 누르기(점/라인 생성)
  // ==========================================
  void _handlePointerDown(PointerDownEvent e) {
    final frame = _frame;
    if (frame == null) return;

    // 생성 중: 두 번째 손가락이면 라인 타입으로 전환 시도
    if (_draftStart != null) {
      _tryConvertToLine(e, frame);
      return;
    }

    // 꾹 누르기 대기 중 다른 손가락이 닿으면 대기 취소 (핀치 등 오작동 방지)
    if (_primaryPointer != null) {
      _cancelPendingPress();
      return;
    }

    _primaryPointer = e.pointer;
    _tapDownPos = e.localPosition;
    _lastPrimaryPos = e.localPosition;

    // 수정/삭제와 신규 생성 모두 설정의 꾹 누르기 시간(widget.longPressSeconds)을 실시간 반영
    final holdDuration = Duration(milliseconds: (widget.longPressSeconds * 1000).toInt());
    final hit = _checkHit(e.localPosition, frame.dates, frame.records, frame.types, frame.dayWidth, widget.yAxisWidth, frame.height);
    if (hit != null) {
      _longPressTimer = Timer(
        holdDuration,
        () {
          if (mounted && _tapDownPos != null) {
            widget.onExecuteLongPress(hit);
            _tapDownPos = null;
          }
        }
      );
    } else if (frame.types.isNotEmpty && _isInChartArea(e.localPosition, frame)) {
      _createTimer = Timer(holdDuration, _startDraft);
    }
  }

  void _handlePointerMove(PointerMoveEvent e) {
    final frame = _frame;
    if (frame == null) return;

    if (_draftStart != null) {
      if (e.pointer == _primaryPointer) {
        setState(() {
          _lastPrimaryPos = e.localPosition;
          _draftStart = _anchorAt(e.localPosition, frame, nearDayIdx: _draftEnd?.dayIdx, allowDayEnd: _draftEnd != null);
        });
      } else if (e.pointer == _secondaryPointer) {
        setState(() {
          _secondaryPos = e.localPosition;
          _draftEnd = _anchorAt(e.localPosition, frame, nearDayIdx: _draftStart!.dayIdx, allowDayEnd: true);
        });
      }
      return;
    }

    if (e.pointer != _primaryPointer || _tapDownPos == null) return;
    _lastPrimaryPos = e.localPosition;
    final slop = (_createTimer?.isActive ?? false) ? _createSlop : _dragSlop;
    if ((e.localPosition - _tapDownPos!).distance > slop) {
      _cancelPendingPress();
    }
  }

  void _handlePointerEnd(PointerEvent e) {
    if (_draftStart != null) {
      if (e.pointer == _primaryPointer) {
        _primaryPointer = null;
        _lastPrimaryPos = null;
      } else if (e.pointer == _secondaryPointer) {
        _secondaryPointer = null;
        _secondaryPos = null;
      } else {
        return;
      }
      // 모든 손가락을 떼면 시간 지정 완료
      if (_primaryPointer == null && _secondaryPointer == null) {
        if (e is PointerCancelEvent) {
          _clearDraft();
        } else {
          _finishDraft();
        }
      }
      return;
    }

    if (e.pointer == _primaryPointer) {
      _cancelPendingPress();
      _primaryPointer = null;
    }
  }

  void _cancelPendingPress() {
    _longPressTimer?.cancel();
    _createTimer?.cancel();
    _tapDownPos = null;
  }

  void _startDraft() {
    final frame = _frame;
    final pos = _lastPrimaryPos;
    if (!mounted || frame == null || pos == null || _tapDownPos == null) return;

    _tapDownPos = null;
    HapticFeedback.mediumImpact();
    setState(() {
      _draftStart = _anchorAt(pos, frame, allowDayEnd: false);
      _draftEnd = null;
      _startDrop = _Drop(_anchorOffset(_draftStart!, frame));
      _endDrop = null;
    });
    _lastDropTick = Duration.zero;
    if (!_dropTicker.isActive) _dropTicker.start();
    // 드래그 중 페이지가 넘어가지 않도록 잠금
    widget.onDraftingChanged(true);
  }

  void _tryConvertToLine(PointerDownEvent e, _ChartFrame frame) {
    if (_primaryPointer == null || _secondaryPointer != null || _draftEnd != null) return;
    // 같은 날짜 칸 또는 바로 옆 칸에 닿은 경우에만 전환
    if ((_dayIdxAt(e.localPosition.dx, frame) - _draftStart!.dayIdx).abs() > 1) return;

    HapticFeedback.heavyImpact();
    setState(() {
      _secondaryPointer = e.pointer;
      _secondaryPos = e.localPosition;
      _draftEnd = _anchorAt(e.localPosition, frame, nearDayIdx: _draftStart!.dayIdx, allowDayEnd: true);
      // 두 번째 물방울은 첫 물방울에서 갈라져 나와 흘러가도록 같은 위치에서 시작
      _endDrop = _Drop(_startDrop?.head ?? _anchorOffset(_draftEnd!, frame));
    });
  }

  // ==========================================
  // 물방울 이펙트 애니메이션
  // ==========================================
  void _onDropTick(Duration elapsed) {
    final frame = _frame;
    final start = _draftStart;
    final startDrop = _startDrop;
    if (!mounted || frame == null || start == null || startDrop == null) return;

    final double dt = ((elapsed - _lastDropTick).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _lastDropTick = elapsed;
    // 꼬리가 너무 길게 늘어지지 않도록 점 반지름의 3배까지만 허용
    final double maxStretch = math.max(_ChartMetrics(frame.dayWidth, widget.dateLabelMode).medRadius, 6.0) * 3;

    setState(() {
      _stepDrop(startDrop, _anchorOffset(start, frame), _primaryPointer != null, dt, maxStretch);
      final end = _draftEnd;
      final endDrop = _endDrop;
      if (end != null && endDrop != null) {
        _stepDrop(endDrop, _anchorOffset(end, frame), _secondaryPointer != null, dt, maxStretch);
      }
    });
  }

  static void _stepDrop(_Drop d, Offset target, bool touching, double dt, double maxStretch) {
    d.age += dt;
    // 드래그 중에는 2배, 손을 떼면 원래 크기로 부드럽게 복귀
    d.grow += ((touching ? _Drop.touchGrow : 1.0) - d.grow) * (1 - math.exp(-dt * 14));
    d.head = Offset.lerp(d.head, target, 1 - math.exp(-dt * 26))!;
    d.tail = Offset.lerp(d.tail, d.head, 1 - math.exp(-dt * 9))!;
    final Offset gap = d.tail - d.head;
    final double stretch = maxStretch * d.grow;
    if (gap.distance > stretch) d.tail = d.head + gap / gap.distance * stretch;
  }

  Offset _anchorOffset(_DraftAnchor a, _ChartFrame frame) {
    final metrics = _ChartMetrics(frame.dayWidth, widget.dateLabelMode);
    const double bottomPadding = 30.0;
    final double chartHeight = frame.height - metrics.topPadding - bottomPadding;
    return Offset(
      widget.yAxisWidth + a.dayIdx * frame.dayWidth + frame.dayWidth / 2,
      metrics.topPadding + (a.minutes / 1440.0) * chartHeight,
    );
  }

  Future<void> _finishDraft() async {
    final frame = _frame;
    final startAnchor = _draftStart;
    final endAnchor = _draftEnd;
    widget.onDraftingChanged(false);
    if (frame == null || startAnchor == null) {
      _clearDraft();
      return;
    }

    DateTime start = _anchorTime(startAnchor, frame.dates);
    DateTime? end = endAnchor != null ? _anchorTime(endAnchor, frame.dates) : null;
    if (end != null) {
      if (end.isBefore(start)) {
        final tmp = start;
        start = end;
        end = tmp;
      }
      if (!end.isAfter(start)) end = null; // 길이 0인 라인은 점으로 처리
    }

    // 팝업이 떠 있는 동안 지정한 위치를 차트에 유지
    await RecordManager.showChartDraftSaveDialog(
      context: context,
      database: widget.database,
      start: start,
      end: end,
      onShowToast: (t, msg) => RecordManager.showRecordToast(context, t, msg),
    );
    _clearDraft();
  }

  void _clearDraft() {
    _primaryPointer = null;
    _secondaryPointer = null;
    _lastPrimaryPos = null;
    _secondaryPos = null;
    widget.onDraftingChanged(false);
    if (mounted) {
      _dropTicker.stop();
      setState(() {
        _draftStart = null;
        _draftEnd = null;
        _startDrop = null;
        _endDrop = null;
      });
    }
  }

  bool _isInChartArea(Offset pos, _ChartFrame frame) {
    final metrics = _ChartMetrics(frame.dayWidth, widget.dateLabelMode);
    return pos.dx >= widget.yAxisWidth && pos.dy >= metrics.topPadding && pos.dy <= frame.height - 30.0;
  }

  int _dayIdxAt(double dx, _ChartFrame frame) =>
      ((dx - widget.yAxisWidth) / frame.dayWidth).floor().clamp(0, frame.dates.length - 1);

  _DraftAnchor _anchorAt(Offset pos, _ChartFrame frame, {int? nearDayIdx, required bool allowDayEnd}) {
    final metrics = _ChartMetrics(frame.dayWidth, widget.dateLabelMode);
    const double bottomPadding = 30.0;
    final double chartHeight = frame.height - metrics.topPadding - bottomPadding;

    int dayIdx = _dayIdxAt(pos.dx, frame);
    if (nearDayIdx != null) {
      // 라인은 같은 칸 또는 옆 칸까지만 (자정을 넘기는 수면 등)
      dayIdx = dayIdx.clamp(nearDayIdx - 1, nearDayIdx + 1).clamp(0, frame.dates.length - 1);
    }

    final double fraction = ((pos.dy - metrics.topPadding) / chartHeight).clamp(0.0, 1.0);
    final int minutes = ((fraction * 1440) / _snapMinutes).round() * _snapMinutes;
    return _DraftAnchor(dayIdx, minutes.clamp(0, allowDayEnd ? 1440 : 1440 - _snapMinutes));
  }

  DateTime _anchorTime(_DraftAnchor a, List<DateTime> dates) {
    final d = dates[a.dayIdx];
    return DateTime(d.year, d.month, d.day, 0, a.minutes);
  }

  String _draftLabel(List<DateTime> dates) {
    final f = DateFormat('M/d(E) HH:mm', 'ko_KR');
    final start = _anchorTime(_draftStart!, dates);
    if (_draftEnd == null) return f.format(start);

    var a = start;
    var b = _anchorTime(_draftEnd!, dates);
    if (b.isBefore(a)) {
      final tmp = a;
      a = b;
      b = tmp;
    }
    final diff = b.difference(a);
    return "${f.format(a)} → ${f.format(b)}  (${diff.inHours}시간 ${diff.inMinutes % 60}분)";
  }

  _HitInfo? _checkHit(Offset pos, List<DateTime> dates, List<CustomDataRecord> records, List<CustomDataType> types, double dayWidth, double left, double height) {
    if (types.isEmpty) return null;
    final metrics = _ChartMetrics(dayWidth, widget.dateLabelMode);
    
    const double bottomPadding = 30.0;
    final double chartHeight = height - metrics.topPadding - bottomPadding;
    final double x = pos.dx - left;
    if (x < 0) return null;

    final int dayIdx = (x / dayWidth).floor();
    if (dayIdx < 0 || dayIdx >= dates.length) return null;
    final targetDate = dates[dayIdx];

    final sleepType = types.firstWhere((t) => t.isPreset && t.name == '수면', orElse: () => types[0]);
    final double centerX = (left + (dayIdx * dayWidth) + (dayWidth / 2)).roundToDouble();

    final dayStartUnix = targetDate.millisecondsSinceEpoch ~/ 1000;
    
    // 터치 보정 범위 확대 (14일/30일 보기 대응)
    final double horizontalHitRange = math.max(metrics.barWidth / 2 + 10, 20.0);
    
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
          
          // 가로 터치 범위 보정
          if (pos.dx >= centerX - horizontalHitRange && pos.dx <= centerX + horizontalHitRange && pos.dy >= startY - 5 && pos.dy <= endY + 5) {
            final dtS = DateTime.fromMillisecondsSinceEpoch((r.unixTimestamp + r.offsetSeconds) * 1000, isUtc: true);
            final dtE = DateTime.fromMillisecondsSinceEpoch((sLocalEnd + r.offsetSeconds) * 1000, isUtc: true);
            final durationStr = "${(sLocalEnd - r.unixTimestamp) ~/ 3600}시간 ${((sLocalEnd - r.unixTimestamp) % 3600) ~/ 60}분";
            return _HitInfo(
              recordId: r.id,
              hitType: 'sleep',
              titleText: "수면 기록 관리",
              subtitleText: "기간: ${DateFormat('HH:mm').format(dtS)} ~ ${DateFormat('HH:mm').format(dtE)} ($durationStr)",
              targetPos: Offset(centerX, pos.dy),
              displayDate: DateFormat('yyyy-MM-dd').format(targetDate),
            );
          }
        }
      } else {
        if (r.unixTimestamp >= dayStartUnix && r.unixTimestamp < dayStartUnix + 86400) {
          final double fractionalDay = (r.unixTimestamp - dayStartUnix) / 86400.0;
          final double y = metrics.topPadding + fractionalDay * chartHeight;
          // 터치 타겟 반경 확대
          final double touchTargetRadius = math.max(metrics.medRadius * 2.5, 25.0);
          
          if ((pos - Offset(centerX, y)).distance <= touchTargetRadius) {
            final dt = DateTime.fromMillisecondsSinceEpoch((r.unixTimestamp + r.offsetSeconds) * 1000, isUtc: true);
            final timeText = DateFormat('HH:mm').format(dt);
            return _HitInfo(
              recordId: r.id,
              hitType: 'custom',
              titleText: "${type.name} 기록 관리",
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
  final ChartDateLabelMode dateLabelMode;

  SleepTimelinePainter({
    required this.dateLabelMode,
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
    final metrics = _ChartMetrics(dayWidth, dateLabelMode);
    const double bottomPadding = 30.0;
    final double chartHeight = size.height - metrics.topPadding - bottomPadding;
    final double chartBottom = metrics.topPadding + chartHeight;

    final gridPaint = Paint()..color = isDarkMode ? Colors.white12 : Colors.black12..strokeWidth = 1;

    // 배경 그리드 (6시간 간격)
    for (int h = 0; h <= 24; h += 6) {
      double y = metrics.topPadding + (h / 24.0) * chartHeight;
      canvas.drawLine(Offset(yAxisWidth, y), Offset(size.width, y), gridPaint);
    }

    final sleepType = types.firstWhere((t) => t.isPreset && t.name == '수면', orElse: () => types[0]);

    for (int i = 0; i < allDates.length; i++) {
      final date = allDates[i];
      final double centerX = yAxisWidth + (i * dayWidth) + (dayWidth / 2);

      // 상단 날짜 라벨
      final String weekdayText = DateFormat('E', 'ko_KR').format(date);
      final String dayText = DateFormat('dd').format(date);
      final Color dateColor = isDarkMode ? Colors.white : Colors.black;
      if (metrics.headerAngle == 0) {
        // 가로 표기: 요일 아래에 날짜, 날짜 아랫면이 차트 상단에서 headerGap만큼 떨어지도록 배치
        final tpLabel = _ChartMetrics.stackedLabelPainter(weekdayText, metrics.labelFontSize);
        final tpDate = _ChartMetrics.stackedDatePainter(dayText, metrics.dateFontSize, dateColor);
        final double dateY = metrics.topPadding - _ChartMetrics.headerGap - tpDate.height;
        tpDate.paint(canvas, Offset(centerX - tpDate.width / 2, dateY));
        tpLabel.paint(canvas, Offset(centerX - tpLabel.width / 2, dateY + _ChartMetrics.stackedOverlap - tpLabel.height));
      } else {
        // 기울여 표기: 시계방향으로 회전해 라벨 끝이 날짜 칸 중앙을 가리키도록 배치
        final tpHeader = _ChartMetrics.headerPainter(weekdayText, dayText, metrics.labelFontSize, metrics.dateFontSize, dateColor);
        // 회전된 라벨의 가장 아래 모서리가 차트 상단에서 headerGap만큼 떨어지도록 끝점 높이 보정
        // (90도일 때는 보정 0 → 라벨이 칸 중앙에 세로로 서고 끝이 차트 바로 위에 옴)
        final double halfH = tpHeader.height / 2 * math.cos(metrics.headerAngle);
        canvas.save();
        canvas.translate(centerX, metrics.topPadding - _ChartMetrics.headerGap - halfH);
        canvas.rotate(metrics.headerAngle);
        tpHeader.paint(canvas, Offset(-tpHeader.width, -tpHeader.height / 2));
        canvas.restore();
      }

      // 날짜 구분 수직선
      canvas.drawLine(Offset(centerX, metrics.topPadding), Offset(centerX, chartBottom), gridPaint);

      final dayStartUnix = date.millisecondsSinceEpoch ~/ 1000;
      final dayEndUnix = dayStartUnix + 86400;
      
      // 해당 날짜에 포함되거나 걸쳐있는 기록 추출
      final dayRecords = records.where((r) {
        int? endUnix;
        if (r.value != null) {
          try {
            final decoded = json.decode(r.value!);
            endUnix = decoded['endUnix'] as int?;
          } catch (_) {}
        }
        final recordEndUnix = endUnix ?? r.unixTimestamp;
        return r.unixTimestamp < dayEndUnix && recordEndUnix > dayStartUnix;
      }).toList();

      // [지능형 2단계 렌더링]
      // 1단계: 모든 막대와 점의 영역을 계산하여 occupiedAreas에 등록
      final List<math.Rectangle<double>> occupiedAreas = [];

      // 수면 막대 그리기 및 영역 등록
      final sleepPaint = Paint()
        ..color = Color(sleepType.colorValue ?? 0xFF4CAF50).withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;

      for (var r in dayRecords) {
        if (r.typeId == sleepType.id) {
          int? endUnix;
          if (r.value != null) {
            try { endUnix = json.decode(r.value!)['endUnix'] as int?; } catch (_) {}
          }
          final sLocalEnd = endUnix ?? r.unixTimestamp;
          final drawStart = math.max(r.unixTimestamp, dayStartUnix);
          final drawEnd = math.min(sLocalEnd, dayEndUnix);

          if (drawStart < drawEnd) {
            final double startY = metrics.topPadding + ((drawStart - dayStartUnix) / 86400.0) * chartHeight;
            final double endY = metrics.topPadding + ((drawEnd - dayStartUnix) / 86400.0) * chartHeight;
            final double cornerRadius = metrics.barWidth / 2;

            final rect = Rect.fromLTRB(centerX - metrics.barWidth/2, startY, centerX + metrics.barWidth/2, endY);
            canvas.drawRRect(RRect.fromRectAndCorners(
              rect, 
              topLeft: r.unixTimestamp >= dayStartUnix ? Radius.circular(cornerRadius) : Radius.zero, 
              topRight: r.unixTimestamp >= dayStartUnix ? Radius.circular(cornerRadius) : Radius.zero, 
              bottomLeft: sLocalEnd <= dayEndUnix ? Radius.circular(cornerRadius) : Radius.zero, 
              bottomRight: sLocalEnd <= dayEndUnix ? Radius.circular(cornerRadius) : Radius.zero
            ), sleepPaint);

            occupiedAreas.add(math.Rectangle(rect.left, rect.top, rect.width, rect.height));
          }
        }
      }

      // 커스텀 이벤트 점 그리기 및 영역 등록
      for (var r in dayRecords) {
        if (r.typeId != sleepType.id) {
          final type = types.firstWhere((t) => t.id == r.typeId, orElse: () => types[0]);
          final typeColor = Color(type.colorValue ?? 0xFF3F51B5);
          final medPaint = Paint()..color = typeColor..style = PaintingStyle.fill;

          final double fractionalDay = (r.unixTimestamp - dayStartUnix) / 86400.0;
          final double medY = metrics.topPadding + fractionalDay * chartHeight;

          canvas.drawCircle(Offset(centerX, medY), metrics.medRadius, medPaint);
          occupiedAreas.add(math.Rectangle(
            centerX - metrics.medRadius, 
            medY - metrics.medRadius, 
            metrics.medRadius * 2, 
            metrics.medRadius * 2
          ));
        }
      }

      // 2단계: 텍스트 라벨 배치 (충돌 감지 및 경계 회피)
      if (showAllDetails) {
        for (var r in dayRecords) {
          if (r.typeId == sleepType.id) {
            int? endUnix;
            if (r.value != null) {
              try { endUnix = json.decode(r.value!)['endUnix'] as int?; } catch (_) {}
            }
            final sLocalEnd = endUnix ?? r.unixTimestamp;

            final double startY = metrics.topPadding + ((r.unixTimestamp - dayStartUnix) / 86400.0) * chartHeight;
            final double endY = metrics.topPadding + ((sLocalEnd - dayStartUnix) / 86400.0) * chartHeight;

            // 취침 시간 (막대 상단)
            if (r.unixTimestamp >= dayStartUnix) {
              final tp = _getTextPainter(_formatUnix(r.unixTimestamp, r.offsetSeconds), metrics.valueFontSize, isDarkMode ? Colors.white70 : Colors.black87);
              
              double textY = startY - 5;
              bool isAbove = true;
              
              // 충돌 및 경계 검사
              var rect = math.Rectangle(centerX - tp.height/2, textY - tp.width, tp.height, tp.width);
              bool hasCollision = occupiedAreas.any((a) => rect.intersects(a)) || rect.top < metrics.topPadding;
              
              if (hasCollision) {
                textY = startY + 5;
                isAbove = false;
                rect = math.Rectangle(centerX - tp.height/2, textY, tp.height, tp.width);
              }
              
              _drawVerticalTextWithPainter(canvas, tp, Offset(centerX, textY), isAbove: isAbove);
              occupiedAreas.add(rect);
            }

            // 기상 시간 (막대 하단)
            if (sLocalEnd <= dayEndUnix) {
              final tp = _getTextPainter(_formatUnix(sLocalEnd, r.offsetSeconds), metrics.valueFontSize, isDarkMode ? Colors.white70 : Colors.black87);
              
              double textY = endY + 5;
              bool isAbove = false;
              
              var rect = math.Rectangle(centerX - tp.height/2, textY, tp.height, tp.width);
              bool hasCollision = occupiedAreas.any((a) => rect.intersects(a)) || rect.bottom > chartBottom;
              
              if (hasCollision) {
                textY = endY - 5;
                isAbove = true;
                rect = math.Rectangle(centerX - tp.height/2, textY - tp.width, tp.height, tp.width);
              }
              
              _drawVerticalTextWithPainter(canvas, tp, Offset(centerX, textY), isAbove: isAbove);
              occupiedAreas.add(rect);
            }

            // [추가] 수면 막대 내부 중앙에 총 수면시간(HH:MM) 표시
            final durationSeconds = sLocalEnd - r.unixTimestamp;
            if (durationSeconds > 1800) { // 30분 이상인 경우에만 시도
              final hours = durationSeconds ~/ 3600;
              final minutes = (durationSeconds % 3600) ~/ 60;
              final durationStr = "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
              
              final tpDur = _getTextPainter(
                durationStr,
                metrics.valueFontSize,
                isDarkMode ? Colors.black : Colors.white, // 바탕색과 대비되도록 (라이트:흰색, 다크:검정)
                isBold: true
              );

              final double barCenterY = startY + (endY - startY) / 2;
              // 막대 내부에 수직으로 배치할 공간이 있는지 확인
              if (endY - startY > tpDur.width + 10) {
                _drawVerticalTextWithPainter(canvas, tpDur, Offset(centerX, barCenterY + tpDur.width/2), isAbove: true);
              }
            }
          } else {
            // 커스텀 이벤트 텍스트
            final type = types.firstWhere((t) => t.id == r.typeId, orElse: () => types[0]);
            final typeColor = Color(type.colorValue ?? 0xFF3F51B5);
            final double medY = metrics.topPadding + ((r.unixTimestamp - dayStartUnix) / 86400.0) * chartHeight;
            
            final bool hasValue = r.value != null && r.value!.trim().isNotEmpty;
            final String txt = hasValue ? "${type.name}: ${r.value}" : _formatUnix(r.unixTimestamp, r.offsetSeconds);
            final tp = _getTextPainter(txt, metrics.valueFontSize, typeColor.withValues(alpha: 0.9), isBold: hasValue);

            double textY = medY - metrics.medRadius - 5;
            bool isAbove = true;
            
            var rect = math.Rectangle(centerX - tp.height/2, textY - tp.width, tp.height, tp.width);
            bool hasCollision = occupiedAreas.any((a) => rect.intersects(a)) || rect.top < metrics.topPadding;
            
            if (hasCollision) {
              textY = medY + metrics.medRadius + 5;
              isAbove = false;
              rect = math.Rectangle(centerX - tp.height/2, textY, tp.height, tp.width);
            }
            
            _drawVerticalTextWithPainter(canvas, tp, Offset(centerX, textY), isAbove: isAbove);
            occupiedAreas.add(rect);
          }
        }
      }
    }
  }

  TextPainter _getTextPainter(String text, double fontSize, Color color, {bool isBold = false}) {
    return TextPainter(text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), textDirection: ui.TextDirection.ltr)..layout();
  }

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

/// 빈 칸 꾹 누르기로 생성 중인 점/라인과 시간 안내 말풍선을 그리는 오버레이
class _DraftPainter extends CustomPainter {
  final List<DateTime> dates;
  final double dayWidth;
  final double left;
  final _DraftAnchor start;
  final _DraftAnchor? end;
  final _Drop startDrop;
  final _Drop? endDrop;
  final Color color;
  final bool isDarkMode;
  final List<Offset> touches; // 현재 화면에 닿아 있는 손가락 위치
  final String label;
  final String? hint;
  final ChartDateLabelMode dateLabelMode;

  _DraftPainter({
    required this.dates,
    required this.dayWidth,
    required this.dateLabelMode,
    required this.left,
    required this.start,
    required this.end,
    required this.startDrop,
    required this.endDrop,
    required this.color,
    required this.isDarkMode,
    required this.touches,
    required this.label,
    this.hint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = _ChartMetrics(dayWidth, dateLabelMode);
    const double bottomPadding = 30.0;
    final double chartHeight = size.height - metrics.topPadding - bottomPadding;

    double xOf(int dayIdx) => left + dayIdx * dayWidth + dayWidth / 2;
    double yOf(int minutes) => metrics.topPadding + (minutes / 1440.0) * chartHeight;

    final dotPaint = Paint()..color = color;
    final double dotRadius = math.max(metrics.medRadius, 6.0);

    double radiusOf(_Drop d) => dotRadius * d.grow * Curves.easeOutBack.transform((d.age / 0.4).clamp(0.0, 1.0));

    // 물방울: 머리 원 + 뒤따라오는 꼬리 원을 곡선 목으로 이어 그림 (외곽선 없음)
    void drawDrop(_Drop d, {bool withTail = true}) {
      final double r = radiusOf(d);
      if (r <= 0) return;
      canvas.drawCircle(d.head, r, dotPaint);
      if (!withTail) return;
      final double dist = (d.tail - d.head).distance;
      if (dist < 0.5) return;
      // 많이 늘어날수록 꼬리가 가늘어짐
      final double tailR = r * (0.6 - 0.2 * (dist / (r * 3)).clamp(0.0, 1.0));
      canvas.drawCircle(d.tail, tailR, dotPaint);
      final neck = _dropNeck(d.head, r, d.tail, tailR);
      if (neck != null) canvas.drawPath(neck, dotPaint);
    }

    final lineEnd = end;
    final endDrop = this.endDrop;
    if (lineEnd != null && endDrop != null) {
      final bool startFirst = start.compareTo(lineEnd) <= 0;
      final a = startFirst ? start : lineEnd;
      final b = startFirst ? lineEnd : start;
      final _Drop aDrop = startFirst ? startDrop : endDrop;
      final _Drop bDrop = startFirst ? endDrop : startDrop;
      final barPaint = Paint()..color = color.withValues(alpha: 0.6);
      final double barR = metrics.barWidth / 2;
      final radius = Radius.circular(barR);

      // 막대 끝은 물방울 꼬리처럼 머리를 한 박자 늦게 따라오고, 머리와는 곡선 목으로 이어짐.
      // 반투명 막대와 목이 겹쳐 진해지지 않도록 하나의 경로로 합쳐서 그림
      void drawBar(int dayIdx, double fromY, double toY, List<(_Drop, double)> ends) {
        final x = xOf(dayIdx);
        Path path = Path();
        if (toY > fromY) {
          path.addRRect(RRect.fromRectAndRadius(Rect.fromLTRB(x - barR, fromY, x + barR, toY), radius));
        }
        for (final (drop, y) in ends) {
          final neck = _dropNeck(drop.head, radiusOf(drop), Offset(x, y), barR);
          if (neck == null) continue;
          neck.addOval(Rect.fromCircle(center: Offset(x, y), radius: barR));
          path = Path.combine(PathOperation.union, path, neck);
        }
        canvas.drawPath(path, barPaint);
      }

      final double aY = aDrop.tail.dy;
      final double bY = bDrop.tail.dy;
      if (a.dayIdx == b.dayIdx) {
        drawBar(a.dayIdx, math.min(aY, bY), math.max(aY, bY), [(aDrop, aY), (bDrop, bY)]);
      } else {
        // 자정을 넘기는 기간: 앞 칸은 24:00까지, 뒤 칸은 00:00부터
        drawBar(a.dayIdx, aY, yOf(1440), [(aDrop, aY)]);
        drawBar(b.dayIdx, yOf(0), bY, [(bDrop, bY)]);
      }
      drawDrop(endDrop, withTail: false);
      drawDrop(startDrop, withTail: false);
    } else {
      drawDrop(startDrop);
    }

    // 손가락 바로 위에 시간 안내 말풍선 표시 (멀티터치: x는 중앙, y는 가장 위 손가락 기준)
    // 다크모드: 배경(0xFF101012)보다 살짝 밝은 회색에 강조색을 은은하게 섞고, 순백 텍스트는 피함
    final Color bubbleColor = isDarkMode
        ? Color.alphaBlend(color.withValues(alpha: 0.18), const Color(0xFF222228))
        : color;
    final Color textColor = isDarkMode ? const Color(0xFFDADAE2) : Colors.white;
    final Color hintColor = isDarkMode ? const Color(0xFF9A9AA6) : Colors.white.withValues(alpha: 0.8);
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(text: label, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
          if (hint != null)
            TextSpan(text: "\n$hint", style: TextStyle(color: hintColor, fontSize: 10)),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: math.max(size.width - 24, 0));

    final Offset touch = touches.isEmpty
        ? Offset(xOf(start.dayIdx), yOf(start.minutes))
        : Offset(
            touches.map((t) => t.dx).reduce((a, b) => a + b) / touches.length,
            touches.map((t) => t.dy).reduce(math.min),
          );
    const double fingerGap = 44.0; // 손가락에 가려지지 않도록 터치 지점에서 띄우는 거리
    const double tailW = 12.0;
    const double tailH = 6.0;
    final double bubbleW = tp.width + 20;
    final double bubbleH = tp.height + 12;
    final double bubbleX = (touch.dx - bubbleW / 2).clamp(left + 4.0, math.max(size.width - bubbleW - 4, left + 4.0));
    final double bubbleY = math.max(touch.dy - fingerGap - tailH - bubbleH, 0.0);
    final bubble = RRect.fromRectAndRadius(Rect.fromLTWH(bubbleX, bubbleY, bubbleW, bubbleH), const Radius.circular(10));

    // 꼬리는 말풍선의 둥근 모서리를 벗어나지 않는 범위에서 터치 x를 가리킴
    final double tailX = touch.dx.clamp(bubbleX + 10 + tailW / 2, bubbleX + bubbleW - 10 - tailW / 2);
    final double bottom = bubbleY + bubbleH;
    final tail = Path()
      ..moveTo(tailX - tailW / 2, bottom - 1)
      ..lineTo(tailX, bottom + tailH)
      ..lineTo(tailX + tailW / 2, bottom - 1)
      ..close();
    final fill = Paint()..color = bubbleColor;
    canvas.drawRRect(bubble, fill);
    canvas.drawPath(tail, fill);
    tp.paint(canvas, Offset(bubbleX + 10, bubbleY + 6));
  }

  // 물방울은 Ticker로 매 프레임 움직이므로 항상 다시 그림
  @override
  bool shouldRepaint(covariant _DraftPainter oldDelegate) => true;
}

/// 머리 원(head, r)과 꼬리 원(tail, tr)을 잇는 물방울 목 경로.
/// 기본은 두 원의 공통 외접선(매끈한 눈물방울 모양)이고, 많이 늘어날수록 양쪽 접점을 안쪽으로 돌려
/// 가운데가 잘록해짐. 옆선은 각 접점에서 원의 접선 방향을 그대로 이어받는 3차 베지어라 경계가 꺾이지 않음
Path? _dropNeck(Offset head, double r, Offset tail, double tr) {
  final Offset delta = tail - head;
  final double d = delta.distance;
  if (r <= 0 || tr <= 0 || d <= (r - tr).abs() || d < 0.5) return null;

  final Offset dir = delta / d;
  final Offset n = Offset(-dir.dy, dir.dx);

  // 외접선 접점 각도(진행 방향 기준)
  final double phi = math.acos(((r - tr) / d).clamp(-1.0, 1.0));
  // 늘어난 정도에 따라 접점을 안쪽으로 회전 (값이 너무 크면 양쪽 옆선이 교차하므로 28°로 제한)
  final double stretch = ((d - (r + tr) * 0.6) / (r * 2.5)).clamp(0.0, 1.0);
  final double pinch = 28 * math.pi / 180 * stretch;
  final double hc = math.cos(phi - pinch);
  final double tc = math.cos(math.pi - phi - pinch * 1.2);
  final double hs = math.sqrt(1 - hc * hc);
  final double ts = math.sqrt(1 - tc * tc);
  final double reach = math.sqrt(math.max(d * d - (r - tr) * (r - tr), 0.0)) * 0.4; // 외접선 길이 기준

  // s = +1 / -1 : 진행 방향 기준 양쪽 옆선
  Offset headPt(double s) => head + dir * (r * hc) + n * (s * r * hs);
  Offset tailPt(double s) => tail - dir * (tr * tc) + n * (s * tr * ts);
  // 각 접점에서 원의 접선 방향 (꼬리 쪽으로 진행하는 방향)
  Offset headTan(double s) => dir * hs - n * (s * hc);
  Offset tailTan(double s) => dir * ts + n * (s * tc);

  final h1 = headPt(1), t1 = tailPt(1), h2 = headPt(-1), t2 = tailPt(-1);
  final c1 = h1 + headTan(1) * reach, c2 = t1 - tailTan(1) * reach;
  final c3 = t2 - tailTan(-1) * reach, c4 = h2 + headTan(-1) * reach;

  return Path()
    ..moveTo(h1.dx, h1.dy)
    ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, t1.dx, t1.dy)
    ..lineTo(t2.dx, t2.dy) // 꼬리 원 내부를 지나는 현이라 보이지 않음
    ..cubicTo(c3.dx, c3.dy, c4.dx, c4.dy, h2.dx, h2.dy)
    ..close(); // 머리 원 내부를 지나는 현
}
