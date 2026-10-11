import 'package:flutter/material.dart';
import '../../core/l10n/app_locale.dart';
import 'statistics_screen.dart';

/// 설정 > 편의성 기능: 테마, 꾹 누르기 시간, 수정취소 알림, 차트 보기 설정
/// (push된 화면은 부모가 다시 빌드해도 갱신되지 않으므로 값을 로컬 상태로 들고 변경 시 콜백으로 전달)
class ConvenienceSettingsScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final double longPressSeconds;
  final ValueChanged<double> onLongPressSecondsChanged;
  final double undoToastSeconds;
  final ValueChanged<double> onUndoToastSecondsChanged;
  final ChartDateLabelMode dateLabelMode;
  final ValueChanged<ChartDateLabelMode> onDateLabelModeChanged;
  final bool showAllDetails;
  final ValueChanged<bool> onShowAllDetailsChanged;

  const ConvenienceSettingsScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.longPressSeconds,
    required this.onLongPressSecondsChanged,
    required this.undoToastSeconds,
    required this.onUndoToastSecondsChanged,
    required this.dateLabelMode,
    required this.onDateLabelModeChanged,
    required this.showAllDetails,
    required this.onShowAllDetailsChanged,
  });

  @override
  State<ConvenienceSettingsScreen> createState() => _ConvenienceSettingsScreenState();
}

class _ConvenienceSettingsScreenState extends State<ConvenienceSettingsScreen> {
  late ThemeMode _themeMode = widget.themeMode;
  late double _longPressSeconds = widget.longPressSeconds;
  late double _undoToastSeconds = widget.undoToastSeconds;
  late ChartDateLabelMode _dateLabelMode = widget.dateLabelMode;
  late bool _showAllDetails = widget.showAllDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr("편의성 기능", "Convenience"))),
      body: ListView(children: [
        _SectionHeader(tr("테마 설정", "Theme")),
        RadioGroup<ThemeMode>(
          groupValue: _themeMode,
          onChanged: (value) {
            setState(() => _themeMode = value!);
            widget.onThemeChanged(value!);
          },
          child: Column(children: [
            RadioListTile<ThemeMode>(title: Text(tr("시스템 설정", "System default")), value: ThemeMode.system),
            RadioListTile<ThemeMode>(title: Text(tr("라이트 모드", "Light mode")), value: ThemeMode.light),
            RadioListTile<ThemeMode>(title: Text(tr("다크 모드", "Dark mode")), value: ThemeMode.dark),
          ]),
        ),
        const Divider(),
        _SectionHeader(tr("꾹 누르기 시간", "Long-press time")),
        ListTile(
          title: Text(tr("통계 차트 꾹 누르기 시간", "Chart long-press time")),
          subtitle: Text(tr("기록 추가·수정·삭제 시 꾹 누르기 시간: ${_longPressSeconds.toStringAsFixed(1)}초",
              "Hold time to add, edit or delete records: ${_longPressSeconds.toStringAsFixed(1)}s")),
          leading: const Icon(Icons.timer_rounded),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Slider(
            value: _longPressSeconds,
            min: 0.5,
            max: 10.0,
            divisions: 19,
            onChanged: (value) {
              setState(() => _longPressSeconds = value);
              widget.onLongPressSecondsChanged(value);
            },
          ),
        ),
        const Divider(),
        _SectionHeader(tr("수정취소 알림", "Undo notice")),
        ListTile(
          title: Text(tr("수정취소 알림 유지 시간", "Undo notice duration")),
          subtitle: Text(tr("차트에서 기록 시간을 수정한 뒤 상단 알림과 수정취소 버튼이 보이는 시간: ${_undoToastSeconds.round()}초",
              "How long the top notice and Undo button stay after editing a time on the chart: ${_undoToastSeconds.round()}s")),
          leading: const Icon(Icons.undo_rounded),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Slider(
            value: _undoToastSeconds,
            min: 2.0,
            max: 15.0,
            divisions: 13,
            onChanged: (value) {
              setState(() => _undoToastSeconds = value);
              widget.onUndoToastSecondsChanged(value);
            },
          ),
        ),
        const Divider(),
        _SectionHeader(tr("차트 보기", "Chart view")),
        ListTile(
          title: Text(tr("날짜 표기", "Date labels")),
          subtitle: Text("${_dateLabelMode.label} · ${_dateLabelMode.description}"),
          leading: const Icon(Icons.text_rotation_angledown_rounded),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DateLabelSettingsScreen(
                mode: _dateLabelMode,
                onChanged: (mode) {
                  setState(() => _dateLabelMode = mode);
                  widget.onDateLabelModeChanged(mode);
                },
              ),
            ),
          ),
        ),
        SwitchListTile(
          title: Text(tr("통계 그래프 상세 시간 표시", "Show detailed times on chart")),
          subtitle: Text(tr("막대 및 점 옆에 기록된 시간을 항상 노출합니다", "Always show recorded times next to bars and dots")),
          value: _showAllDetails,
          secondary: const Icon(Icons.segment_rounded),
          onChanged: (value) {
            setState(() => _showAllDetails = value);
            widget.onShowAllDetailsChanged(value);
          },
        ),
      ]),
    );
  }
}

/// 설정 > 편의성 기능 > 차트 보기 > 날짜 표기
class DateLabelSettingsScreen extends StatefulWidget {
  final ChartDateLabelMode mode;
  final ValueChanged<ChartDateLabelMode> onChanged;

  const DateLabelSettingsScreen({super.key, required this.mode, required this.onChanged});

  @override
  State<DateLabelSettingsScreen> createState() => _DateLabelSettingsScreenState();
}

class _DateLabelSettingsScreenState extends State<DateLabelSettingsScreen> {
  late ChartDateLabelMode _mode = widget.mode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr("날짜 표기", "Date labels"))),
      body: ListView(children: [
        _SectionHeader(tr("통계 차트 상단의 요일·날짜 표기 방식", "How weekdays and dates appear above the chart")),
        RadioGroup<ChartDateLabelMode>(
          groupValue: _mode,
          onChanged: (value) {
            setState(() => _mode = value!);
            widget.onChanged(value!);
          },
          child: Column(children: [
            for (final mode in ChartDateLabelMode.values)
              RadioListTile<ChartDateLabelMode>(
                title: Text(mode.label),
                subtitle: Text(mode.description),
                value: mode,
              ),
          ]),
        ),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;

  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
