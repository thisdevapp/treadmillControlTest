import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../database/database.dart';
import 'record_manager.dart';

/// 기록 버튼(데이터 타입)의 추가, 수정, 삭제 및 아이콘 선택 UI를 전담하는 모듈
class RecordTypeManager {
  /// 새 기록 버튼을 추가하거나 기존 버튼을 수정하는 통합 다이얼로그 호출
  static void showAddOrEditTypeDialog({
    required BuildContext context,
    required AppDatabase database,
    CustomDataType? type,
    required VoidCallback onSaved,
  }) {
    final isEdit = type != null;
    final nameController = TextEditingController(text: type?.name ?? "");
    String selectedIcon = type?.iconName ?? "medication";
    int selectedColorValue = type?.colorValue ?? 0xFF3F51B5;

    // 기본 프리셋 아이콘 목록
    final List<Map<String, dynamic>> presetIcons = [
      {'name': 'medication', 'icon': Icons.medication_rounded},
      {'name': 'coffee', 'icon': Icons.local_cafe_rounded},
      {'name': 'smoke', 'icon': Icons.smoking_rooms_rounded},
      {'name': 'sports', 'icon': Icons.directions_run_rounded},
      {'name': 'beer', 'icon': Icons.local_bar_rounded},
      {'name': 'star', 'icon': Icons.star_rounded},
      {'name': 'favorite', 'icon': Icons.favorite_rounded},
      {'name': 'mood', 'icon': Icons.mood_rounded},
      {'name': 'water', 'icon': Icons.water_drop_rounded},
      {'name': 'food', 'icon': Icons.restaurant_rounded}
    ];

    // '기타 아이콘' 선택을 위한 전체 목록 (주요 아이콘 세트)
    final List<IconData> allMaterialIcons = [
      Icons.favorite, Icons.star, Icons.home, Icons.settings, Icons.person,
      Icons.shopping_cart, Icons.camera_alt, Icons.image, Icons.audiotrack, Icons.movie,
      Icons.directions_run, Icons.directions_bike, Icons.directions_car, Icons.flight, Icons.hotel,
      Icons.restaurant, Icons.local_cafe, Icons.local_bar, Icons.fastfood, Icons.cake,
      Icons.pets, Icons.nature, Icons.wb_sunny, Icons.nightlight_round, Icons.umbrella,
      Icons.school, Icons.work, Icons.build, Icons.auto_stories, Icons.edit,
      Icons.event, Icons.alarm, Icons.timer, Icons.timer_outlined, Icons.calculate,
      Icons.phone, Icons.email, Icons.chat, Icons.share, Icons.map,
      Icons.security, Icons.lightbulb, Icons.eco, Icons.face, Icons.celebration,
      Icons.sports_soccer, Icons.sports_basketball, Icons.fitness_center, Icons.medication, Icons.healing,
      Icons.smoking_rooms, Icons.smoke_free, Icons.water_drop, Icons.bolt, Icons.local_fire_department,
      Icons.videogame_asset, Icons.mouse, Icons.keyboard, Icons.smartphone, Icons.headset,
    ];

    final List<int> presetColors = [
      0xFF3F51B5, 0xFF4CAF50, 0xFFFF9800, 0xFFE91E63, 
      0xFF009688, 0xFF9C27B0, 0xFF2196F3, 0xFF795548
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          final Color currentThemeColor = Color(selectedColorValue);

          // 현재 선택된 아이콘이 프리셋에 없는 '기타 아이콘'인 경우 미리보기 생성
          Widget buildCustomIconPreview() {
            bool isPreset = presetIcons.any((i) => i['name'] == selectedIcon);
            if (isPreset) return const SizedBox.shrink();

            IconData customIcon;
            try {
              customIcon = IconData(int.parse(selectedIcon), fontFamily: 'MaterialIcons');
            } catch (e) {
              customIcon = Icons.help_outline;
            }

            return Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  Text("선택된 기타 아이콘", 
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: currentThemeColor)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: currentThemeColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(customIcon, size: 36, color: currentThemeColor),
                  ),
                ],
              ),
            );
          }

          return AlertDialog(
            title: Text(isEdit ? "기록 버튼 수정" : "새 기록 버튼 추가", 
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "이름", 
                      border: OutlineInputBorder(),
                      hintText: "예: 비타민, 아메리카노"
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("아이콘 선택", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      ...presetIcons.map((i) {
                        final bool isSelected = selectedIcon == i['name'];
                        return GestureDetector(
                          onTap: () => setDlgState(() => selectedIcon = i['name']),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? currentThemeColor.withValues(alpha: 0.1) : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              i['icon'], 
                              size: 32, 
                              color: isSelected ? currentThemeColor : Colors.grey.withValues(alpha: 0.6)
                            ),
                          ),
                        );
                      }),
                      // '기타 아이콘' 선택용 더보기 버튼
                      GestureDetector(
                        onTap: () => _showFullIconPicker(
                          context: context,
                          allIcons: allMaterialIcons,
                          onSelected: (code) => setDlgState(() => selectedIcon = code),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
                          child: const Icon(Icons.more_horiz_rounded, size: 32, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  buildCustomIconPreview(),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("테마 색상", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ...presetColors.map((c) => GestureDetector(
                        onTap: () => setDlgState(() => selectedColorValue = c),
                        child: CircleAvatar(
                          backgroundColor: Color(c),
                          radius: 16,
                          child: selectedColorValue == c ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                        ),
                      )),
                      // [커스텀 색상 선택 버튼] - 그라데이션 원형
                      GestureDetector(
                        onTap: () => _showCustomColorPicker(
                          context: context,
                          initialColor: currentThemeColor,
                          onColorSelected: (newColor) => setDlgState(() => selectedColorValue = newColor.toARGB32()),
                        ),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: presetColors.contains(selectedColorValue) ? Colors.grey.shade300 : currentThemeColor,
                              width: presetColors.contains(selectedColorValue) ? 1 : 3,
                            ),
                            gradient: const SweepGradient(
                              colors: [
                                Colors.red, Colors.orange, Colors.yellow, 
                                Colors.green, Colors.blue, Colors.indigo, 
                                Colors.purple, Colors.red
                              ],
                            ),
                          ),
                          child: !presetColors.contains(selectedColorValue) 
                              ? const Icon(Icons.colorize, size: 16, color: Colors.white)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx), 
                child: const Text("취소")
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: currentThemeColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (nameController.text.isEmpty) return;
                  if (isEdit) {
                    await database.updateCustomDataTypeInfo(type.id, nameController.text, selectedIcon, selectedColorValue);
                  } else {
                    await database.addCustomDataType(
                      name: nameController.text, 
                      iconName: selectedIcon, 
                      colorValue: selectedColorValue,
                    );
                  }
                  onSaved();
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(isEdit ? "수정 완료" : "생성"),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 커스텀 컬러 피커 호출
  static void _showCustomColorPicker({
    required BuildContext context,
    required Color initialColor,
    required Function(Color) onColorSelected,
  }) {
    Color pickedColor = initialColor;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("커스텀 색상 선택"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: (color) => pickedColor = color,
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hsvWithHue,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
          FilledButton(
            onPressed: () {
              onColorSelected(pickedColor);
              Navigator.pop(ctx);
            },
            child: const Text("선택"),
          ),
        ],
      ),
    );
  }

  /// Material Icons 전체 목록을 보여주는 바텀 시트
  static void _showFullIconPicker({
    required BuildContext context,
    required List<IconData> allIcons,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("기타 아이콘 선택", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: allIcons.length,
                itemBuilder: (ctx, idx) => IconButton(
                  icon: Icon(allIcons[idx], size: 30, color: Colors.indigo),
                  onPressed: () {
                    onSelected(allIcons[idx].codePoint.toString());
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 기록 버튼 삭제 확인 다이얼로그
  static void confirmDeleteType({
    required BuildContext context,
    required AppDatabase database,
    required CustomDataType type,
    required VoidCallback onDeleteDone,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("버튼 삭제", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("'${type.name}' 버튼과 관련된 모든 기록이 영구적으로 삭제됩니다. 계속하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
          TextButton(
            onPressed: () async {
              await database.deleteCustomDataType(type.id);
              onDeleteDone();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("삭제", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
