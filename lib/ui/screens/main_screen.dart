import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/database.dart';
import '../widgets/record_manager.dart';
import '../widgets/record_type_manager.dart';
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
    return RecordManager.getIconData(name);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🏗️ MainScreen build 시작 (Theme: ${Theme.of(context).brightness})");
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
            onPressed: () => RecordTypeManager.showAddOrEditTypeDialog(
              context: context, 
              database: widget.database, 
              onSaved: () {}
            ),
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
  // [1] 기록 대시보드
  // ==========================================
  Widget _buildDashboardView() {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;
    final int columns = isTablet ? 6 : 4;

    return StreamBuilder<List<CustomDataType>>(
      stream: widget.database.watchCustomDataTypes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("❌ StreamBuilder 에러 발생: ${snapshot.error}");
          return Center(child: Text("데이터 로드 에러: ${snapshot.error}"));
        }
        
        if (!snapshot.hasData) {
          debugPrint("⏳ 데이터 대기 중 (StreamBuilder)...");
          return const Center(child: CircularProgressIndicator());
        }
        
        final types = snapshot.data!;
        
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
          if (constraints.maxWidth < 100 || constraints.maxHeight < 100) {
            return const Center(child: Text("화면 크기 대기 중..."));
          }

          final double horizontalPadding = 48;
          final double verticalPadding = 48;
          final double cellWidth = (constraints.maxWidth - horizontalPadding) / columns;
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
                  if (_isEditMode) _buildGridGuide(constraints.maxWidth - horizontalPadding, cellHeight, 6, columns),
                  
                  if (_activeId != null) Positioned(
                    left: _ghostX * cellWidth,
                    top: _ghostY * cellHeight,
                    width: _ghostW * cellWidth,
                    height: _ghostH * cellHeight,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.indigo.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.indigo.withValues(alpha: 0.3), width: 2, strokeAlign: BorderSide.strokeAlignOutside),
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

  Widget _buildPositionedWidget(CustomDataType type, double cellW, double cellH) {
    final bool isActive = _activeId == type.id;
    final bool isMoving = isActive && !_isResizing;
    final bool isResizing = isActive && _isResizing;
    
    return AnimatedPositioned(
      duration: isActive ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      left: isMoving ? _dragX : type.gridX * cellW,
      top: isMoving ? _dragY : type.gridY * cellH,
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
    final bool isResizing = isActive && _isResizing;

    final int currentW = isResizing ? _ghostW : type.gridWidth;
    final int currentH = isResizing ? _ghostH : type.gridHeight;
    final bool isSmall = currentW == 1 && currentH == 1;
    
    final Color color = Color(type.colorValue ?? Colors.indigo.toARGB32());
    final int maxCol = MediaQuery.of(context).size.width > 600 ? 6 : 4;

    final Color themeBgColor = Theme.of(context).scaffoldBackgroundColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _isEditMode ? (details) {
        final double lx = details.localPosition.dx;
        final double ly = details.localPosition.dy;
        final double cardW = cellW * type.gridWidth;
        final double cardH = cellH * type.gridHeight;
        
        if (lx > cardW - 50 && ly > cardH - 50) {
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
          double deltaX = details.globalPosition.dx - _startGlobalX;
          double deltaY = details.globalPosition.dy - _startGlobalY;
          int newW = (_startGridW + deltaX / cellW).round().clamp(1, maxCol - type.gridX);
          int newH = (_startGridH + deltaY / cellH).round().clamp(1, 6);
          if (newW != _ghostW || newH != _ghostH) {
            setState(() {
              _ghostW = newW;
              _ghostH = newH;
            });
          }
        } else {
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
          color: color.withValues(alpha: 0.2), // 배경색 투명도를 20%로 설정
          borderRadius: BorderRadius.circular(isSmall ? 18 : 24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1), // 그림자도 더 은은하게 조정
              blurRadius: isActive ? 20 : 10, 
              offset: isActive ? const Offset(0, 8) : const Offset(0, 4)
            )
          ],
          // 편집 모드 시 테마에 따라 대비되는 테두리 표시
          border: _isEditMode ? Border.all(color: color.withValues(alpha: isActive ? 1.0 : 0.3), width: isActive ? 3 : 1.5) : null,
        ),
        child: Stack(
          children: [
            // 아이콘과 텍스트 컬러를 해당 데이터 컬러(color)로 적용
            _buildWidgetContent(type, currentW, currentH, color),
            if (_isEditMode) ...[
              Positioned(
                top: 4, right: 0, left: 0,
                child: Icon(Icons.drag_handle_rounded, size: 14, color: themeBgColor.withValues(alpha: 0.5))
              ),
              Positioned(
                top: -2, left: -2,
                child: IconButton(
                  icon: Icon(Icons.remove_circle, size: 18, color: themeBgColor),
                  onPressed: () => RecordTypeManager.confirmDeleteType(
                    context: context, 
                    database: widget.database, 
                    type: type, 
                    onDeleteDone: () {}
                  ),
                ),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 50, height: 50,
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isResizing ? Colors.red.withValues(alpha: 0.2) : themeBgColor.withValues(alpha: 0.1),
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

  Widget _buildWidgetContent(CustomDataType type, int w, int h, Color iconColor) {
    final bool isHorizontal = w > h;
    final IconData iconData = _getIconData(type.iconName);
    final Brightness brightness = Theme.of(context).brightness;
    final Color textColor = brightness == Brightness.dark ? Colors.white : Colors.black;

    if (isHorizontal) {
      return LayoutBuilder(builder: (context, constraints) {
        final double minSide = constraints.maxWidth < constraints.maxHeight ? constraints.maxWidth : constraints.maxHeight;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconData, color: iconColor, size: minSide * 0.5),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    type.name,
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: -0.5, 
                      color: textColor, // 모드에 따라 검정/흰색 적용
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
    } else {
      return LayoutBuilder(builder: (context, constraints) {
        final double minSide = constraints.maxWidth < constraints.maxHeight ? constraints.maxWidth : constraints.maxHeight;
        final bool isSmall = w == 1 && h == 1;
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(flex: 5, child: Center(child: Icon(iconData, color: iconColor, size: minSide * (isSmall ? 0.45 : 0.55)))),
              Expanded(
                flex: 2, 
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown, 
                    alignment: Alignment.topCenter, 
                    child: Text(
                      type.name, 
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w900, 
                        letterSpacing: -0.5, 
                        color: textColor, // 모드에 따라 검정/흰색 적용
                      ),
                    ),
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
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.withValues(alpha: 0.05))),
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
    HapticFeedback.mediumImpact();
    if (type.name == '수면') {
      RecordManager.showSleepLogDialog(
        context: context,
        database: widget.database,
        sleepTypeId: type.id,
        onShowToast: _showToast,
      );
    } else {
      RecordManager.quickLogEvent(
        context: context,
        database: widget.database,
        type: type,
        onShowToast: _showToast,
      );
    }
  }

  void _showToast(CustomDataType type, String message) {
    RecordManager.showRecordToast(context, type, message);
  }

  void _showWidgetMenu(CustomDataType type) {
    final color = Color(type.colorValue ?? Colors.indigo.toARGB32());
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
                onTap: () => RecordManager.quickLogEvent(
                  context: context,
                  database: widget.database,
                  type: type,
                  onShowToast: _showToast,
                ),
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
                  RecordManager.showSleepLogDialog(
                    context: context,
                    database: widget.database,
                    sleepTypeId: type.id,
                    onShowToast: _showToast,
                  );
                } else {
                  RecordManager.showAddPastRecordDialog(
                    context: context,
                    database: widget.database,
                    type: type,
                    onShowToast: _showToast,
                  );
                }
              },
            ),
            const Divider(color: Colors.white24, indent: 16, endIndent: 16),
            _menuOption(
              ctx,
              icon: Icons.note_add_rounded,
              label: "메모 추가",
              onColor: onColor,
              onTap: () => RecordManager.showMemoDialog(
                context: context,
                database: widget.database,
                type: type,
                onShowToast: _showToast,
              ),
            ),
            const Divider(color: Colors.white24, indent: 16, endIndent: 16),
            _menuOption(
              ctx,
              icon: Icons.settings_suggest_rounded,
              label: "기록 수정",
              onColor: onColor,
              onTap: () => RecordTypeManager.showAddOrEditTypeDialog(
                context: context, 
                database: widget.database, 
                type: type, 
                onSaved: () {}
              ),
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

  Widget _counterField(String label, int val, Function(int) onChg) => Column(children: [
    Text(label, style: const TextStyle(fontSize: 10)),
    Row(children: [
      IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () => onChg(val - 1)),
      Text("$val", style: const TextStyle(fontWeight: FontWeight.bold)),
      IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () => onChg(val + 1)),
    ])
  ]);

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
