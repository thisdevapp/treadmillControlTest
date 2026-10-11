import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/l10n/app_locale.dart';
import '../../database/database.dart';
import 'record_manager.dart';

/// 하단 바 중앙의 큰 + 버튼
/// - 한 번 누르기: [onTap] (마지막에 추가한 점 데이터 다시 추가). false를 돌려주면 다이얼을 대신 엶
/// - 꾹 누르기: 버튼 위에 데이터 종류를 부채꼴 다이얼로 펼침. 손가락을 끌어 항목 위에서 떼면 바로 선택,
///   빈 곳에서 떼면 다이얼이 열린 채로 남아 항목을 누르거나(선택) 꾹 눌러(관리 메뉴) 사용할 수 있음
///   맨 오른쪽 무채색 + 는 새 데이터 종류 추가
class QuickAddButton extends StatefulWidget {
  final AppDatabase database;
  final Color color;
  final Color iconColor;
  final Future<bool> Function() onTap;
  final ValueChanged<CustomDataType> onSelectType;
  final ValueChanged<CustomDataType> onTypeMenu;
  final VoidCallback onAddType;

  static const double size = 68.0;

  const QuickAddButton({
    super.key,
    required this.database,
    required this.color,
    required this.iconColor,
    required this.onTap,
    required this.onSelectType,
    required this.onTypeMenu,
    required this.onAddType,
  });

  @override
  State<QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<QuickAddButton> {
  StreamSubscription<List<CustomDataType>>? _typesSub;
  List<CustomDataType> _types = [];

  OverlayEntry? _dial;
  final ValueNotifier<int?> _hover = ValueNotifier(null); // 손가락이 올라가 있는 다이얼 항목
  List<Offset> _itemCenters = []; // 다이얼 항목 중심 (전역 좌표). 마지막은 + 항목
  double _itemSize = 52;
  bool _pressed = false;

  static const double _itemGap = 12.0;

  @override
  void initState() {
    super.initState();
    _typesSub = widget.database.watchCustomDataTypes().listen((types) {
      // 다이얼은 만든 순서대로 (새로 만든 종류가 + 바로 왼쪽에 오도록)
      _types = [...types]..sort((a, b) => a.id.compareTo(b.id));
      _dial?.markNeedsBuild();
    });
  }

  @override
  void dispose() {
    _typesSub?.cancel();
    _dial?.remove();
    _dial = null;
    _hover.dispose();
    super.dispose();
  }

  // ==========================================
  // 다이얼 열기/닫기
  // ==========================================
  void _openDial() {
    if (_dial != null) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final Offset center = box.localToGlobal(box.size.center(Offset.zero));
    _layoutItems(center, MediaQuery.sizeOf(context));

    HapticFeedback.mediumImpact();
    _hover.value = null;
    _dial = OverlayEntry(builder: (_) => _buildDial(center));
    Overlay.of(context, rootOverlay: true).insert(_dial!);
  }

  void _closeDial() {
    _dial?.remove();
    _dial = null;
    _hover.value = null;
  }

  /// 버튼 위쪽 부채꼴(165° → 15°)에 항목을 왼쪽부터 순서대로 배치.
  /// 항목이 많으면 반지름을 키우고, 화면 폭을 넘으면 항목 크기를 줄임
  void _layoutItems(Offset center, Size screen) {
    final int n = _types.length + 1;
    const double startAngle = 165 * math.pi / 180;
    const double endAngle = 15 * math.pi / 180;
    const double span = startAngle - endAngle;
    final double maxRadius = math.min(screen.width / 2 - 36, 220.0);

    double size = 52;
    double radius = 110;
    if (n > 1) {
      radius = math.max(radius, (size + _itemGap) * (n - 1) / span);
      if (radius > maxRadius) {
        radius = maxRadius;
        size = math.max(radius * span / (n - 1) - _itemGap * 0.5, 30.0);
      }
    }
    _itemSize = size;
    _itemCenters = List.generate(n, (i) {
      final double a = n == 1 ? math.pi / 2 : startAngle - span * i / (n - 1);
      return center + Offset(math.cos(a) * radius, -math.sin(a) * radius);
    });
  }

  int? _itemAt(Offset global) {
    // 항목 간격의 절반까지는 해당 항목으로 판정 (손가락에 가려도 고르기 쉽도록)
    final double hitRadius = _itemSize / 2 + _itemGap;
    int? best;
    double bestDist = hitRadius;
    for (var i = 0; i < _itemCenters.length; i++) {
      final double d = (global - _itemCenters[i]).distance;
      if (d <= bestDist) {
        best = i;
        bestDist = d;
      }
    }
    return best;
  }

  void _select(int index) {
    final types = _types;
    _closeDial();
    HapticFeedback.mediumImpact();
    if (index < types.length) {
      widget.onSelectType(types[index]);
    } else {
      widget.onAddType();
    }
  }

  void _openMenu(int index) {
    if (index >= _types.length) return;
    final type = _types[index];
    _closeDial();
    HapticFeedback.heavyImpact();
    widget.onTypeMenu(type);
  }

  // ==========================================
  // 다이얼 UI
  // ==========================================
  Widget _buildDial(Offset center) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color addColor = isDark ? const Color(0xFF55555C) : const Color(0xFFB0B0B8);
    final Color labelColor = isDark ? const Color(0xFFDADAE2) : const Color(0xFF303036);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      // 오버레이에는 Material이 없어 텍스트에 노란 밑줄(기본 스타일 없음 표시)이 생기므로 투명 Material로 감쌈
      builder: (context, t, _) => Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            // 바깥을 누르면 닫힘
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeDial,
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.35 * t.clamp(0.0, 1.0))),
              ),
            ),
            for (var i = 0; i < _itemCenters.length; i++)
              _buildItem(
                index: i,
                // 버튼에서 튀어나와 제자리로 펼쳐짐
                pos: Offset.lerp(center, _itemCenters[i], t)!,
                opacity: t.clamp(0.0, 1.0),
                type: i < _types.length ? _types[i] : null,
                addColor: addColor,
                labelColor: labelColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required int index,
    required Offset pos,
    required double opacity,
    required CustomDataType? type,
    required Color addColor,
    required Color labelColor,
  }) {
    final double s = _itemSize;
    const double labelH = 16;
    return Positioned(
      left: pos.dx - s / 2 - 8,
      top: pos.dy - s / 2,
      width: s + 16,
      height: s + labelH + 4,
      child: Opacity(
        opacity: opacity,
        child: ValueListenableBuilder<int?>(
          valueListenable: _hover,
          builder: (context, hover, _) {
            final bool active = hover == index;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _select(index),
              onLongPress: type == null ? null : () => _openMenu(index),
              child: Column(
                children: [
                  AnimatedScale(
                    scale: active ? 1.25 : 1.0,
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOut,
                    child: Container(
                      width: s,
                      height: s,
                      decoration: BoxDecoration(
                        color: type == null ? addColor : Color(type.colorValue ?? Colors.indigo.toARGB32()),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: active ? 0.3 : 0.15), blurRadius: active ? 12 : 6, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Icon(
                        type == null ? Icons.add_rounded : RecordManager.getIconData(type.iconName),
                        color: widget.iconColor,
                        size: s * 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: labelH,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        type?.label ?? tr("새 기록", "New record"),
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w900 : FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // 버튼
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () async {
        setState(() => _pressed = false);
        HapticFeedback.mediumImpact();
        if (!await widget.onTap() && mounted) _openDial();
      },
      onLongPressStart: (_) {
        setState(() => _pressed = false);
        _openDial();
      },
      onLongPressMoveUpdate: (d) {
        final int? hit = _itemAt(d.globalPosition);
        if (hit != _hover.value) {
          if (hit != null) HapticFeedback.selectionClick();
          _hover.value = hit;
        }
      },
      onLongPressEnd: (_) {
        final int? hit = _hover.value;
        if (hit != null) {
          _select(hit);
        } else {
          _hover.value = null; // 빈 곳에서 떼면 다이얼을 열어 둔 채로 항목을 누를 수 있게 함
        }
      },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: QuickAddButton.size,
          height: QuickAddButton.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: widget.color.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Icon(Icons.add_rounded, color: widget.iconColor, size: 42),
        ),
      ),
    );
  }
}
