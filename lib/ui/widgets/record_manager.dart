import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/database.dart';
import 'custom_picker_utils.dart';

class RecordManager {
  static IconData getIconData(String? name) {
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

  static void showRecordToast(BuildContext context, CustomDataType type, String message) {
    final color = Color(type.colorValue ?? Colors.indigo.value);
    final onColor = Theme.of(context).scaffoldBackgroundColor;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(getIconData(type.iconName), color: onColor, size: 20),
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

  static Future<void> quickLogEvent({
    required BuildContext context,
    required AppDatabase database,
    required CustomDataType type,
    Function(CustomDataType, String)? onShowToast,
  }) async {
    final now = DateTime.now();
    // 가장 최근 기록의 메모 상속
    final lastRecord = await database.getLastRecord(type.id);
    String? memo;
    if (lastRecord != null && lastRecord.value != null) {
      if (type.name != '수면') {
        memo = lastRecord.value;
      }
    }

    await database.addCustomDataRecord(
      typeId: type.id, 
      timestamp: now,
      value: memo,
    );
    
    onShowToast?.call(type, memo != null ? "${type.name} 기록 완료 (메모 상속됨)" : "${type.name} 기록 완료");
  }

  static Future<void> showAddPastRecordDialog({
    required BuildContext context,
    required AppDatabase database,
    required CustomDataType type,
    Function(CustomDataType, String)? onShowToast,
    int? existingRecordId,
    DateTime? initialTimestamp,
    String? initialValue,
  }) async {
    DateTime finalTime = initialTimestamp ?? DateTime.now();
    final memoController = TextEditingController(text: initialValue);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          title: Row(
            children: [
              Icon(getIconData(type.iconName), color: Colors.indigo, size: 28),
              const SizedBox(width: 12),
              Text(existingRecordId != null ? "${type.name} 기록 수정" : "${type.name} 과거 기록 추가", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("날짜, 시간 및 내용을 설정해주세요.", style: TextStyle(fontSize: 15, color: Colors.grey)),
                  const SizedBox(height: 28),
                  
                  _buildTimeTile(
                    context: context,
                    label: "기록 시간",
                    dateTime: finalTime,
                    onChanged: (newDt) => setDlgState(() => finalTime = newDt),
                  ),
                  
                  const SizedBox(height: 28),
                  TextField(
                    controller: memoController,
                    maxLines: 10,
                    minLines: 5,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      labelText: "메모 (선택)",
                      labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      hintText: "내용을 입력하세요.",
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: const Text("취소", style: TextStyle(fontSize: 17))
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                final memoValue = memoController.text.trim().isEmpty ? null : memoController.text.trim();
                
                if (existingRecordId != null) {
                  await database.updateCustomDataRecord(existingRecordId, timestamp: finalTime, value: memoValue);
                } else {
                  await database.addCustomDataRecord(
                    typeId: type.id,
                    timestamp: finalTime,
                    value: memoValue,
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(existingRecordId != null ? "수정하기" : "저장하기", 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    if (context.mounted) {
      onShowToast?.call(type, existingRecordId != null ? "${type.name} 기록이 수정되었습니다." : "${type.name} 과거 기록이 추가되었습니다.");
    }
  }

  static Future<void> showMemoDialog({
    required BuildContext context,
    required AppDatabase database,
    required CustomDataType type,
    Function(CustomDataType, String)? onShowToast,
    int? existingRecordId,
    String? initialValue,
  }) async {
    final memoController = TextEditingController(text: initialValue);
    
    // 1단계: 메모 입력
    final bool? memoConfirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existingRecordId != null ? "${type.name} 메모 수정" : "${type.name} 메모 작성"),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: memoController,
            autofocus: true,
            maxLines: 20,
            minLines: 10,
            decoration: const InputDecoration(
              labelText: "메모 입력",
              hintText: "예:\n- 아메리카노 300ml\n- 비타민 C\n- 타이레놀 1정",
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("취소")),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(existingRecordId != null ? "수정 완료" : "다음 (기간 설정)"),
          ),
        ],
      ),
    );

    if (memoConfirmed != true) return;

    if (existingRecordId != null) {
      await database.updateCustomDataRecord(existingRecordId, value: memoController.text.trim());
      if (context.mounted) onShowToast?.call(type, "${type.name} 메모 수정됨");
      return;
    }

    // 2단계: 기간 설정 (새 메모 작성 시에만)
    if (!context.mounted) return;
    
    final now = DateTime.now();
    DateTime startDT = DateTime(now.year, now.month, now.day, 0, 0);
    DateTime endDT = DateTime(now.year, now.month, now.day, 23, 59);

    final bool? periodConfirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text("메모 적용 기간 설정"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("선택한 기간 내의 모든 기록에\n이 메모가 적용됩니다.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 16),
              _buildTimeTile(
                context: context,
                label: "시작",
                dateTime: startDT,
                onChanged: (newDt) => setDlgState(() => startDT = newDt),
              ),
              const SizedBox(height: 8),
              _buildTimeTile(
                context: context,
                label: "종료",
                dateTime: endDT,
                onChanged: (newDt) => setDlgState(() => endDT = newDt),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("이전")),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("메모 적용"),
            ),
          ],
        ),
      ),
    );

    if (periodConfirmed == true) {
      await database.updateRecordsValueInPeriod(
        typeId: type.id,
        start: startDT,
        end: endDT,
        value: memoController.text.trim(),
      );
      
      if (context.mounted) {
        onShowToast?.call(type, "기간 내 메모가 적용되었습니다.");
      }
    }
  }

  static Future<void> showSleepLogDialog({
    required BuildContext context,
    required AppDatabase database,
    required int sleepTypeId,
    Function(CustomDataType, String)? onShowToast,
    DateTime? initialStart,
    DateTime? initialEnd,
    int? existingRecordId,
    String? initialMemo,
  }) async {
    final now = DateTime.now();
    DateTime startDT = initialStart ?? DateTime(now.year, now.month, now.day, 23, 0).subtract(const Duration(days: 1));
    DateTime endDT = initialEnd ?? DateTime(now.year, now.month, now.day, 7, 0);
    final memoController = TextEditingController(text: initialMemo);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          title: Row(
            children: [
              const Icon(Icons.bedtime_rounded, color: Colors.indigo, size: 28),
              const SizedBox(width: 12),
              Text(existingRecordId != null ? "수면 기록 수정" : "수면 기록 추가", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("취침 및 기상 시간을 설정해주세요.", style: TextStyle(fontSize: 15, color: Colors.grey)),
                  const SizedBox(height: 28),
                  
                  _buildTimeTile(
                    context: context,
                    label: "취침 시간",
                    dateTime: startDT,
                    onChanged: (newDt) => setDlgState(() => startDT = newDt),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTimeTile(
                    context: context,
                    label: "기상 시간",
                    dateTime: endDT,
                    onChanged: (newDt) => setDlgState(() => endDT = newDt),
                  ),
                  
                  const SizedBox(height: 28),
                  TextField(
                    controller: memoController,
                    maxLines: 15,
                    minLines: 10,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      labelText: "수면 메모 (선택)",
                      labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      hintText: "내용을 자유롭게 기록하세요.",
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: const Text("취소", style: TextStyle(fontSize: 17))
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                if (endDT.isBefore(startDT)) {
                  endDT = endDT.add(const Duration(days: 1));
                }

                final val = jsonEncode({
                  'endUnix': endDT.millisecondsSinceEpoch ~/ 1000,
                  'memo': memoController.text.trim(),
                });
                
                if (existingRecordId != null) {
                  await database.updateCustomDataRecord(existingRecordId, timestamp: startDT, value: val);
                } else {
                  await database.addCustomDataRecord(typeId: sleepTypeId, timestamp: startDT, value: val);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(existingRecordId != null ? "수정하기" : "저장하기", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    if (context.mounted) {
      final types = await database.getCustomDataTypes();
      final sleepType = types.firstWhere((t) => t.id == sleepTypeId);
      onShowToast?.call(sleepType, existingRecordId != null ? "수면 기록이 수정되었습니다." : "수면 기록이 저장되었습니다.");
    }
  }

  static Widget _buildTimeTile({
    required BuildContext context,
    required String label,
    required DateTime dateTime,
    required Function(DateTime) onChanged,
  }) {
    final f = DateFormat('MM/dd HH:mm');
    return InkWell(
      onTap: () async {
        final d = await CustomPickerUtils.pickDate(context: context, initialDate: dateTime);
        if (d != null && context.mounted) {
          final t = await CustomPickerUtils.pickTime(context: context, initialTime: TimeOfDay.fromDateTime(dateTime));
          if (t != null) {
            onChanged(DateTime(d.year, d.month, d.day, t.hour, t.minute));
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(f.format(dateTime), style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
