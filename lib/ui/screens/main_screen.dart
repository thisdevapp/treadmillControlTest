import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;
import '../../database/database.dart';
import '../widgets/custom_picker_utils.dart';
import 'statistics_screen.dart';

class MainScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;
  final AppDatabase database;

  const MainScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.database,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  double _longPressSeconds = 4.0;
  bool _isEditMode = false;

  // 드래그 및 리사이즈 상태 관리
  int? _activeId;
  bool _isResizing = false;
  double _dragX = 0;
  double _dragY = 0;
  double _startGlobalX = 0;
  double _startGlobalY = 0;
  int _startGridW = 1;
  int _startGridH = 1;
  int _ghostX = 0;
  int _ghostY = 0;
  int _ghostW = 1;
  int _ghostH = 1;

  final List<String> _titles = ["기록 대시보드", "통계 분석", "환경 설정"];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _checkDataIntegrity() async {
    final columns = MediaQuery.of(context).size.width > 600 ? 6 : 4;
    await widget.database.fixDataIntegrity(columns: columns);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _longPressSeconds = prefs.getDouble('long_press_seconds') ?? 4.0;
    });
  }

  Future<void> _saveLongPressSeconds(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('long_press_seconds', value);
    setState(() {
      _longPressSeconds = value;
    });
  }

  IconData _getIconData(String? name) {
    switch (name) {
      case 'hotel': return Icons.hotel_rounded;
      case 'medication': return Icons.medication_rounded;
      case 'coffee': return Icons.local_cafe_rounded;
      case 'smoke': return Icons.smoking_rooms_rounded;
      case 'sports': return Icons.directions_run_rounded;
      case 'beer': return Icons.local_bar_rounded;
      case 'star': return Icons.star_rounded;
      case 'favorite': return Icons.favorite_rounded;
      case 'mood': return Icons.mood_rounded;
      case 'water': return Icons.water_drop_rounded;
      case 'food': return Icons.restaurant_rounded;
      default: return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light ? const Color(0xFFF0F2F8) : const Color(0xFF101012),
      appBar: AppBar(
        title: Text(_titles[_selectedIndex], style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1.0)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: _selectedIndex == 0 ? [
          IconButton(
            icon: Icon(_isEditMode ? Icons.check_circle_rounded : Icons.edit_attributes_rounded, color: _isEditMode ? Colors.green : null),
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _showAddOrEditTypeDialog(onSaved: () {}),
          ),
        ] : null,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardView(),
          StatisticsScreen(database: widget.database, longPressSeconds: _longPressSeconds),
          _buildSettingsView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: "기록"),
          NavigationDestination(icon: Icon(Icons.analytics_rounded), label: "통계"),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: "설정"),
        ],
      ),
    );
  }

  // ==========================================
  // [1] 기록 대시보드 (날짜 제거, 프리셋 강화)
  // ==========================================
  Widget _buildDashboardView() {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;
    final int columns = isTablet ? 6 : 4;

    return StreamBuilder<List<CustomDataType>>(
      stream: widget.database.watchCustomDataTypes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final types = snapshot.data!;
        
        // 데이터가 전혀 없는 경우 프리셋 버튼 생성 제안
        if (types.isEmpty) {
          return Center(child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome_motion_rounded, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text("대시보드 구성이 비어있습니다.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    await widget.database.fixDataIntegrity(columns: columns);
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("기본 버튼 세트 생성 및 복구"),
                )
              ],
            ),
          ));
        }

        return LayoutBuilder(builder: (context, constraints) {
          // 세로 방향으로 스크롤 없이 보이기 위해 타겟 행(Row) 설정
          final double horizontalPadding = 48; // (24 * 2)
          final double verticalPadding = 48;
          
          final double cellWidth = (constraints.maxWidth - horizontalPadding) / columns;
          
          // 한 화면에 약 6행이 딱 들어오도록 계산 (오버플로우 방지)
          final double cellHeight = (constraints.maxHeight - verticalPadding) / 6;

          return GestureDetector(
            onTap: () {
              if (_isEditMode) {
                setState(() => _isEditMode = false);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              padding: const EdgeInsets.all(24),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 가이드라인이 부모 높이를 넘지 않도록 6행으로 제한
                  if (_isEditMode) _buildGridGuide(constraints.maxWidth - horizontalPadding, cellHeight, 6, columns),
                  
                  // 드래그 중인 고스트(가이드) 표시
                  if (_activeId != null) Positioned(
                    left: _ghostX * cellWidth,
                    top: _ghostY * cellHeight,
                    width: _ghostW * cellWidth,
                    height: _ghostH * cellHeight,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.indigo.withOpacity(0.3), width: 2, strokeAlign: BorderSide.strokeAlignOutside),
                        ),
                      ),
                    ),
                  ),

                  ...types.map((type) => _buildPositionedWidget(type, cellWidth, cellHeight)),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  // 기본 프리셋 생성 (수면 1x1 버튼을 왼쪽 상단 0,0에 배치)
  Future<void> _createDefaultPreset() async {
    await widget.database.addCustomDataType(
      name: '수면', iconName: 'hotel', colorValue: 0xFF4CAF50, isPreset: true,
      x: 0, y: 0, w: 1, h: 1,
    );
  }

  Widget _buildPositionedWidget(CustomDataType type, double cellW, double cellH) {
    final bool isActive = _activeId == type.id;
    final bool isMoving = isActive && !_isResizing;
    final bool isResizing = isActive && _isResizing;
    
    return AnimatedPositioned(
      duration: isActive ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      // 이동 중일 때만 드래그 좌표 사용, 리사이즈 중에는 위치 고정
      left: isMoving ? _dragX : type.gridX * cellW,
      top: isMoving ? _dragY : type.gridY * cellH,
      // 리사이즈 중에는 고스트 크기를 즉시 반영하여 실시간으로 변화하게 함
      width: isResizing ? _ghostW * cellW : type.gridWidth * cellW,
      height: isResizing ? _ghostH * cellH : type.gridHeight * cellH,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: _buildWidgetCard(type, cellW, cellH),
      ),
    );
  }

  Widget _buildWidgetCard(CustomDataType type, double cellW, double cellH) {
    final bool isActive = _activeId == type.id;
    final bool isMoving = isActive && !_isResizing;
    final bool isResizing = isActive && _isResizing;

    // 현재 상호작용 중인 크기 반영 (리사이즈 중이면 고스트 크기 사용)
    final int currentW = isResizing ? _ghostW : type.gridWidth;
    final int currentH = isResizing ? _ghostH : type.gridHeight;
    final bool isSmall = currentW == 1 && currentH == 1;
    
    final Color color = Color(type.colorValue ?? Colors.indigo.value);
    final int maxCol = MediaQuery.of(context).size.width > 600 ? 6 : 4;

    final Color themeBgColor = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _isEditMode ? (details) {
        final double lx = details.localPosition.dx;
        final double ly = details.localPosition.dy;
        final double cardW = cellW * type.gridWidth;
        final double cardH = cellH * type.gridHeight;
        
        print("🚩 [PAN START] ID: ${type.id}, Pos: (${lx.toStringAsFixed(1)}, ${ly.toStringAsFixed(1)}), CardSize: (${cardW.toStringAsFixed(1)}, ${cardH.toStringAsFixed(1)})");

        // 리사이즈 핸들 영역(우측 하단 50x50으로 확대) 인지 확인
        if (lx > cardW - 50 && ly > cardH - 50) {
          print("📐 [RESIZE MODE START] ID: ${type.id}");
          setState(() {
            _activeId = type.id;
            _isResizing = true;
            _startGlobalX = details.globalPosition.dx;
            _startGlobalY = details.globalPosition.dy;
            _startGridW = type.gridWidth;
            _startGridH = type.gridHeight;
            _ghostX = type.gridX;
            _ghostY = type.gridY;
            _ghostW = type.gridWidth;
            _ghostH = type.gridHeight;
          });
        } else {
          print("🚚 [MOVE MODE START] ID: ${type.id}");
          setState(() {
            _activeId = type.id;
            _isResizing = false;
            _dragX = type.gridX * cellW;
            _dragY = type.gridY * cellH;
            _ghostX = type.gridX;
            _ghostY = type.gridY;
            _ghostW = type.gridWidth;
            _ghostH = type.gridHeight;
          });
        }
      } : null,
      onPanUpdate: _isEditMode ? (details) {
        if (_activeId != type.id) return;

        if (_isResizing) {
          // 리사이즈 로직
          double deltaX = details.globalPosition.dx - _startGlobalX;
          double deltaY = details.globalPosition.dy - _startGlobalY;
          
          int newW = (_startGridW + deltaX / cellW).round().clamp(1, maxCol - type.gridX);
          int newH = (_startGridH + deltaY / cellH).round().clamp(1, 6); // 화면 내로 제한
          
          if (newW != _ghostW || newH != _ghostH) {
            print("📐 [RESIZE UPDATE] $newW x $newH");
            setState(() {
              _ghostW = newW;
              _ghostH = newH;
            });
          }
        } else {
          // 이동 로직
          setState(() {
            _dragX += details.delta.dx;
            _dragY += details.delta.dy;
            _ghostX = (_dragX / cellW).round().clamp(0, maxCol - type.gridWidth);
            _ghostY = (_dragY / cellH).round().clamp(0, 6);
          });
        }
      } : null,
      onPanEnd: _isEditMode ? (details) async {
        if (_activeId != type.id) return;

        final int finalId = type.id;
        final int finalX = _isResizing ? type.gridX : _ghostX;
        final int finalY = _isResizing ? type.gridY : _ghostY;
        final int finalW = _isResizing ? _ghostW : type.gridWidth;
        final int finalH = _isResizing ? _ghostH : type.gridHeight;

        print("🏁 [PAN END] ID: $finalId, Mode: ${_isResizing ? 'RESIZE' : 'MOVE'}, Result: ($finalX, $finalY) ${finalW}x$finalH");

        setState(() {
          _activeId = null;
          _isResizing = false;
        });

        await widget.database.updateCustomDataTypeLayout(finalId, finalX, finalY, finalW, finalH);
        await widget.database.fixDataIntegrity(columns: maxCol);
      } : null,
      onTap: _isEditMode ? null : () => _onWidgetTap(type),
      onDoubleTap: _isEditMode ? null : () {
        HapticFeedback.mediumImpact();
        _showWidgetMenu(type);
      },
      onLongPress: _isEditMode ? null : () {
        HapticFeedback.heavyImpact();
        setState(() => _isEditMode = true);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color, // 배경색을 데이터 고유 색상으로 변경
          borderRadius: BorderRadius.circular(isSmall ? 18 : 24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isActive ? 0.5 : 0.2), 
              blurRadius: isActive ? 20 : 10, 
              offset: isActive ? const Offset(0, 8) : const Offset(0, 4)
            )
          ],
          // 편집 모드 시 테마에 따라 대비되는 테두리 표시
          border: _isEditMode ? Border.all(color: themeBgColor.withOpacity(isActive ? 1.0 : 0.3), width: isActive ? 3 : 1.5) : null,
        ),
        child: Stack(
          children: [
            // 아이콘과 텍스트를 현재 테마의 배경색(scaffoldBackgroundColor)으로 표시
            _buildWidgetContent(type, currentW, currentH, themeBgColor),
            if (_isEditMode) ...[
              // 이동 핸들 아이콘 (중앙 상단)
              Positioned(
                top: 4, right: 0, left: 0,
                child: Icon(Icons.drag_handle_rounded, size: 14, color: themeBgColor.withOpacity(0.5))
              ),
              // 삭제 버튼 (좌측 상단)
              Positioned(
                top: -2, left: -2,
                child: IconButton(
                  icon: Icon(Icons.remove_circle, size: 18, color: themeBgColor),
                  onPressed: () => _confirmDeleteType(type, () {}),
                ),
              ),
              // 리사이즈 핸들 (우측 하단)
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 50, height: 50,
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isResizing ? Colors.red.withOpacity(0.2) : themeBgColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(bottomRight: Radius.circular(18)),
                  ),
                  child: Icon(
                    Icons.south_east_rounded, 
                    size: 24, 
                    color: isResizing ? Colors.redAccent : themeBgColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetContent(CustomDataType type, int w, int h, Color foregroundColor) {
    final bool isHorizontal = w > h;
    final IconData iconData = _getIconData(type.iconName);

    if (isHorizontal) {
      // [가로형 레이아웃] 아이콘 좌측, 텍스트 우측
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // 아이콘 영역 (정사각 유지)
            AspectRatio(
              aspectRatio: 1,
              child: LayoutBuilder(builder: (context, constraints) {
                return Icon(iconData, color: foregroundColor, size: constraints.maxHeight * 0.5);
              }),
            ),
            const SizedBox(width: 8),
            // 텍스트 영역
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(type.name,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: foregroundColor)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // [세로형/정사각 레이아웃] 아이콘 중앙, 텍스트 하단
      return LayoutBuilder(builder: (context, constraints) {
        final double minSide = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final bool isSmall = w == 1 && h == 1;

        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // 아이콘 (상단/중앙)
              Expanded(
                flex: 5,
                child: Center(
                  child: Icon(iconData,
                      color: foregroundColor, size: minSide * (isSmall ? 0.45 : 0.55)),
                ),
              ),
              // 텍스트 (하단 고정)
              Expanded(
                flex: 2,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: Text(type.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: foregroundColor,
                        )),
                  ),
                ),
              ),
            ],
          ),
        );
      });
    }
  }

  Widget _buildGridGuide(double width, double cellH, int rows, int columns) {
    return Column(children: List.generate(rows, (y) => Row(children: List.generate(columns, (x) => Container(
      width: width / columns, height: cellH,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.05))),
    )))));
  }

  // ==========================================
  // [2] 설정 탭 뷰
  // ==========================================
  Widget _buildSettingsView() {
    return ListView(children: [
      const Padding(padding: EdgeInsets.all(16.0), child: Text("환경 설정", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      RadioListTile<ThemeMode>(title: const Text("시스템 설정"), value: ThemeMode.system, groupValue: widget.currentThemeMode, onChanged: (value) => widget.onThemeChanged(value!)),
      RadioListTile<ThemeMode>(title: const Text("라이트 모드"), value: ThemeMode.light, groupValue: widget.currentThemeMode, onChanged: (value) => widget.onThemeChanged(value!)),
      RadioListTile<ThemeMode>(title: const Text("다크 모드"), value: ThemeMode.dark, groupValue: widget.currentThemeMode, onChanged: (value) => widget.onThemeChanged(value!)),
      const Divider(),
      ListTile(title: const Text("데이터 삭제를 위한 길게 누르기 시간"), subtitle: Text("통계 지표 꾹 누르기 시간: ${_longPressSeconds.toStringAsFixed(1)}초"), leading: const Icon(Icons.timer_rounded)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Slider(value: _longPressSeconds, min: 1.0, max: 10.0, divisions: 18, onChanged: (value) => _saveLongPressSeconds(value))),
      const Divider(),
      ListTile(title: const Text("모든 데이터 초기화"), subtitle: const Text("영구 파괴 및 대시보드 리셋"), leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent), onTap: () => _confirmResetAllData()),
    ]);
  }

  // ==========================================
  // [3] 비즈니스 로직
  // ==========================================
  void _onWidgetTap(CustomDataType type) {
    HapticFeedback.mediumImpact(); // 햅틱 반응 추가
    if (type.name == '수면') {
      _showSleepLogDialog(type.id);
    } else {
      _quickLogEvent(type);
    }
  }

  Future<void> _quickLogEvent(CustomDataType type) async {
    final now = DateTime.now();
    await widget.database.addCustomDataRecord(typeId: type.id, timestamp: now);
    _showToast(type, "${type.name} 기록 완료");
  }

  void _showToast(CustomDataType type, String message) {
    if (!mounted) return;
    final color = Color(type.colorValue ?? Colors.indigo.value);
    final onColor = Theme.of(context).scaffoldBackgroundColor;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getIconData(type.iconName), color: onColor, size: 20),
            const SizedBox(width: 12),
            Text(
              message,
              style: TextStyle(color: onColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
        elevation: 4,
      ),
    );
  }

  void _showLayoutEditDialog(CustomDataType type) {
    int x = type.gridX; int y = type.gridY; int w = type.gridWidth; int h = type.gridHeight;
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDlgState) => AlertDialog(
      title: Text("${type.name} 위젯 설정"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("위치 (X, Y 좌표)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _counterField("X", x, (v) => setDlgState(() => x = v.clamp(0, 3))),
          _counterField("Y", y, (v) => setDlgState(() => y = v.clamp(0, 20))),
        ]),
        const SizedBox(height: 16),
        const Text("크기 (가로, 세로 칸 수)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _counterField("가로", w, (v) => setDlgState(() => w = v.clamp(1, 4))),
          _counterField("세로", h, (v) => setDlgState(() => h = v.clamp(1, 4))),
        ]),
      ]),
      actions: [
        TextButton(onPressed: () => _confirmDeleteType(type, () => Navigator.pop(ctx)), child: const Text("삭제", style: TextStyle(color: Colors.red))),
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
        FilledButton(onPressed: () async {
          await widget.database.updateCustomDataTypeLayout(type.id, x, y, w, h);
          if (ctx.mounted) Navigator.pop(ctx);
        }, child: const Text("저장")),
      ],
    )));
  }

  Future<void> _showPastRecordDialog(CustomDataType type) async {
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
          title: Text("${type.name} 과거 기록 추가"),
          content: TextField(
            controller: memoController,
            maxLines: 5,
            minLines: 3,
            decoration: const InputDecoration(
              labelText: "세부 내용 (선택)",
              hintText: "예:\n- 졸피뎀 10mg\n- 마그네슘 200mg\n- 아메리카노",
              alignLabelWithHint: true,
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
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  _showToast(type, "${type.name} 과거 기록 추가됨");
                }
              },
              child: const Text("저장"),
            )
          ],
        ),
      );
    }
  }

  void _showWidgetMenu(CustomDataType type) {
    final color = Color(type.colorValue ?? Colors.indigo.value);
    final onColor = Theme.of(context).scaffoldBackgroundColor;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type.name != '수면') ...[
              _menuOption(
                ctx,
                icon: Icons.add_circle_outline_rounded,
                label: "지금 기록 추가",
                onColor: onColor,
                onTap: () => _quickLogEvent(type),
              ),
              const Divider(color: Colors.white24, indent: 16, endIndent: 16),
            ],
            _menuOption(
              ctx,
              icon: Icons.history_rounded,
              label: "지난 기록 추가",
              onColor: onColor,
              onTap: () {
                if (type.name == '수면') {
                  _showSleepLogDialog(type.id);
                } else {
                  _showPastRecordDialog(type);
                }
              },
            ),
            const Divider(color: Colors.white24, indent: 16, endIndent: 16),
            _menuOption(
              ctx,
              icon: Icons.note_add_rounded,
              label: "메모 추가",
              onColor: onColor,
              onTap: () => _showMemoDialog(type),
            ),
            const Divider(color: Colors.white24, indent: 16, endIndent: 16),
            _menuOption(
              ctx,
              icon: Icons.settings_suggest_rounded,
              label: "기록 수정",
              onColor: onColor,
              onTap: () => _showAddOrEditTypeDialog(type: type, onSaved: () {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuOption(BuildContext dialogCtx,
      {required IconData icon, required String label, required Color onColor, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: onColor),
      title: Text(label, style: TextStyle(color: onColor, fontWeight: FontWeight.bold, fontSize: 16)),
      onTap: () {
        Navigator.pop(dialogCtx);
        onTap();
      },
    );
  }

  void _showMemoDialog(CustomDataType type) {
    final memoController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("${type.name} 메모 기록"),
        content: TextField(
          controller: memoController,
          autofocus: true,
          maxLines: 5,
          minLines: 3,
          decoration: const InputDecoration(
            labelText: "메모 입력",
            hintText: "예:\n- 타이레놀 1알\n- 비타민C 1000mg",
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
          FilledButton(
            onPressed: () async {
              await widget.database.addCustomDataRecord(
                typeId: type.id,
                timestamp: DateTime.now(),
                value: memoController.text.trim().isEmpty ? null : memoController.text.trim(),
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                _showToast(type, "${type.name} 기록됨");
              }
            },
            child: const Text("기록"),
          ),
        ],
      ),
    );
  }

  Widget _counterField(String label, int val, Function(int) onChg) => Column(children: [
    Text(label, style: const TextStyle(fontSize: 10)),
    Row(children: [
      IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () => onChg(val - 1)),
      Text("$val", style: const TextStyle(fontWeight: FontWeight.bold)),
      IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () => onChg(val + 1)),
    ])
  ]);

  void _showAddOrEditTypeDialog({CustomDataType? type, required VoidCallback onSaved}) {
    final isEdit = type != null;
    final nameController = TextEditingController(text: type?.name ?? "");
    String selectedIcon = type?.iconName ?? "medication";
    int selectedColor = type?.colorValue ?? 0xFF3F51B5;
    
    final List<Map<String, dynamic>> icons = [{'name': 'medication', 'icon': Icons.medication_rounded}, {'name': 'coffee', 'icon': Icons.local_cafe_rounded}, {'name': 'smoke', 'icon': Icons.smoking_rooms_rounded}, {'name': 'sports', 'icon': Icons.directions_run_rounded}, {'name': 'beer', 'icon': Icons.local_bar_rounded}, {'name': 'star', 'icon': Icons.star_rounded}, {'name': 'favorite', 'icon': Icons.favorite_rounded}, {'name': 'mood', 'icon': Icons.mood_rounded}, {'name': 'water', 'icon': Icons.water_drop_rounded}, {'name': 'food', 'icon': Icons.restaurant_rounded}];
    final List<int> colors = [0xFF3F51B5, 0xFF4CAF50, 0xFFFF9800, 0xFFE91E63, 0xFF009688, 0xFF9C27B0, 0xFF2196F3, 0xFF795548];
    
    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDlgState) => AlertDialog(
      title: Text(isEdit ? "기록 버튼 수정" : "새 기록 버튼 추가"),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameController, decoration: const InputDecoration(labelText: "이름", border: OutlineInputBorder())),
        const SizedBox(height: 16),
        const Text("아이콘 선택", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: icons.map((i) => ChoiceChip(avatar: Icon(i['icon'], size: 16), label: const Text(""), selected: selectedIcon == i['name'], onSelected: (s) => setDlgState(() => selectedIcon = i['name']))).toList()),
        const SizedBox(height: 16),
        const Text("테마 색상", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(spacing: 12, runSpacing: 12, children: colors.map((c) => GestureDetector(onTap: () => setDlgState(() => selectedColor = c), child: CircleAvatar(backgroundColor: Color(c), radius: 14, child: selectedColor == c ? const Icon(Icons.check, size: 14, color: Colors.white) : null))).toList()),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
        FilledButton(onPressed: () async {
          if (nameController.text.isEmpty) return;
          if (isEdit) {
            await widget.database.updateCustomDataTypeInfo(type.id, nameController.text, selectedIcon, selectedColor);
          } else {
            await widget.database.addCustomDataType(name: nameController.text, iconName: selectedIcon, colorValue: selectedColor, x: 0, y: 0, w: 1, h: 1);
            await widget.database.fixDataIntegrity(columns: MediaQuery.of(context).size.width > 600 ? 6 : 4);
          }
          onSaved();
          if (ctx.mounted) Navigator.pop(ctx);
        }, child: Text(isEdit ? "수정 완료" : "생성")),
      ],
    )));
  }

  void _showSleepLogDialog(int sleepTypeId) {
    final now = DateTime.now();
    DateTime startDT = DateTime(now.year, now.month, now.day, 22, 0);
    DateTime endDT = DateTime(now.year, now.month, now.day, 7, 0).add(const Duration(days: 1));
    int quality = 3;
    final memoController = TextEditingController();

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDlgState) => AlertDialog(
      title: const Text("수면 기록"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        OutlinedButton(onPressed: () async { final d = await CustomPickerUtils.pickDate(context: context, initialDate: startDT); if (d != null) setDlgState(() => startDT = DateTime(d.year, d.month, d.day, startDT.hour, startDT.minute)); }, child: Text("취침: ${DateFormat('MM/dd HH:mm').format(startDT)}")),
        OutlinedButton(onPressed: () async { final d = await CustomPickerUtils.pickDate(context: context, initialDate: endDT); if (d != null) setDlgState(() => endDT = DateTime(d.year, d.month, d.day, endDT.hour, endDT.minute)); }, child: Text("기상: ${DateFormat('MM/dd HH:mm').format(endDT)}")),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(icon: Icon(i < quality ? Icons.star : Icons.star_border, color: Colors.amber), onPressed: () => setDlgState(() => quality = i + 1)))),
        TextField(controller: memoController, decoration: const InputDecoration(labelText: "메모")),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
        FilledButton(onPressed: () async {
          final val = jsonEncode({'endUnix': endDT.millisecondsSinceEpoch ~/ 1000, 'quality': quality, 'memo': memoController.text});
          await widget.database.addCustomDataRecord(typeId: sleepTypeId, timestamp: startDT, value: val);
          if (ctx.mounted) {
            Navigator.pop(ctx);
            // 수면 타입 정보를 가져와서 토스트 표시
            final types = await widget.database.getCustomDataTypes();
            final sleepType = types.firstWhere((t) => t.id == sleepTypeId);
            _showToast(sleepType, "수면 기록 저장됨");
          }
        }, child: const Text("저장")),
      ],
    )));
  }

  void _confirmDeleteType(CustomDataType type, VoidCallback onDeleteDone) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("버튼 삭제"),
      content: const Text("이 버튼과 관련된 모든 기록이 삭제됩니다. 계속하시겠습니까?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
        TextButton(onPressed: () async {
          await widget.database.deleteCustomDataType(type.id);
          onDeleteDone();
          if (ctx.mounted) Navigator.pop(ctx);
        }, child: const Text("삭제", style: TextStyle(color: Colors.red))),
      ],
    ));
  }

  void _confirmResetAllData() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("전체 초기화"),
      content: const Text("모든 설정과 데이터를 초기화하시겠습니까?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
        TextButton(onPressed: () async {
          await widget.database.transaction(() async {
            await widget.database.delete(widget.database.customDataRecords).go();
            await widget.database.delete(widget.database.customDataTypes).go();
          });
          final columns = MediaQuery.of(context).size.width > 600 ? 6 : 4;
          await widget.database.fixDataIntegrity(columns: columns);
          if (ctx.mounted) Navigator.pop(ctx);
        }, child: const Text("초기화", style: TextStyle(color: Colors.red))),
      ],
    ));
  }
}
