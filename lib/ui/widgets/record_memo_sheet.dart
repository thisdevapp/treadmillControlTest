import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/l10n/app_locale.dart';
import '../../core/memo/record_memo.dart';
import '../../database/database.dart';
import 'record_manager.dart';

/// 통계 화면에서 기록을 탭했을 때 여는 메모 모달
/// - 메모가 있으면 보기 모달 (마크다운 본문 + 첨부 사진 + 위치)
/// - 없으면 작성 모달
class RecordMemoSheet {
  RecordMemoSheet._();

  static Future<void> open({
    required BuildContext context,
    required CustomDataRecord record,
    required CustomDataType type,
  }) async {
    final memo = await MemoStore.instance.load(record.id);
    if (!context.mounted) return;
    if (memo != null) {
      await _showViewer(context, record, type, memo);
    } else {
      await _showEditor(context, record, type, null);
    }
  }

  static Future<void> _showViewer(BuildContext context, CustomDataRecord record, CustomDataType type, RecordMemo memo) async {
    final action = await showModalBottomSheet<_ViewerAction>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _MemoViewer(record: record, type: type, memo: memo),
    );
    if (!context.mounted) return;
    switch (action) {
      case _ViewerAction.edit:
        await _showEditor(context, record, type, memo);
      case _ViewerAction.delete:
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(tr("메모 삭제", "Delete memo")),
            content: Text(tr("메모와 첨부한 사진을 삭제하시겠습니까?\n기록 자체는 남아 있습니다.",
                "Delete this memo and its photos?\nThe record itself is kept.")),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr("취소", "Cancel"))),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(tr("삭제", "Delete"), style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (ok == true) {
          await MemoStore.instance.delete(record.id);
          if (context.mounted) RecordManager.showRecordToast(context, type, tr("메모를 삭제했습니다", "Memo deleted"));
        }
      case null:
        break;
    }
  }

  static Future<void> _showEditor(BuildContext context, CustomDataRecord record, CustomDataType type, RecordMemo? memo) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false, // 작성 중 실수로 내려 닫히지 않도록 (닫기는 버튼/뒤로가기로)
      builder: (_) => _MemoEditor(record: record, type: type, memo: memo, initialText: memo?.markdown ?? _legacyMemo(record)),
    );
    if (saved != true || !context.mounted) return;
    // 저장 후 바로 결과를 보여줌 (내용을 모두 지워 메모가 삭제된 경우는 제외)
    final updated = await MemoStore.instance.load(record.id);
    if (!context.mounted) return;
    if (updated != null) {
      RecordManager.showRecordToast(context, type, tr("메모를 저장했습니다", "Memo saved"));
      await _showViewer(context, record, type, updated);
    }
  }

  /// 메모 기능 이전에 기록에 함께 저장하던 메모 (수면: JSON의 memo, 그 외: value). 새 메모 작성 시 초안으로 사용
  static String _legacyMemo(CustomDataRecord record) {
    final value = record.value?.trim();
    if (value == null || value.isEmpty) return '';
    try {
      final decoded = json.decode(value);
      if (decoded is Map) return (decoded['memo'] as String?)?.trim() ?? '';
    } catch (_) {}
    return value;
  }

  /// 모달 상단에 보이는 기록 시각 (수면은 기간)
  static String timeText(CustomDataRecord record) {
    DateTime local(int unix) => DateTime.fromMillisecondsSinceEpoch((unix + record.offsetSeconds) * 1000, isUtc: true);
    final f = DateFormat(tr('M월 d일 (E) HH:mm', 'EEE, MMM d HH:mm'), AppLocale.intl);
    final start = local(record.unixTimestamp);
    int? endUnix;
    try {
      final decoded = json.decode(record.value ?? '');
      if (decoded is Map) endUnix = decoded['endUnix'] as int?;
    } catch (_) {}
    if (endUnix == null) return f.format(start);
    final end = local(endUnix);
    final d = endUnix - record.unixTimestamp;
    return "${f.format(start)} ~ ${DateFormat('HH:mm').format(end)} (${trDuration(d ~/ 3600, (d % 3600) ~/ 60)})";
  }
}

enum _ViewerAction { edit, delete }

/// 모달 상단: 기록 종류 아이콘 + 이름 + 시각
class _MemoHeader extends StatelessWidget {
  final CustomDataRecord record;
  final CustomDataType type;
  final List<Widget> actions;

  const _MemoHeader({required this.record, required this.type, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final Color color = Color(type.colorValue ?? Colors.indigo.toARGB32());
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color,
          child: Icon(RecordManager.getIconData(type.iconName), color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(type.label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(RecordMemoSheet.timeText(record), style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
        ),
        ...actions,
      ],
    );
  }
}

// ==========================================
// 보기 모달
// ==========================================
class _MemoViewer extends StatelessWidget {
  final CustomDataRecord record;
  final CustomDataType type;
  final RecordMemo memo;

  const _MemoViewer({required this.record, required this.type, required this.memo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          _MemoHeader(
            record: record,
            type: type,
            actions: [
              IconButton(
                tooltip: tr("메모 수정", "Edit memo"),
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => Navigator.pop(context, _ViewerAction.edit),
              ),
              IconButton(
                tooltip: tr("메모 삭제", "Delete memo"),
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: () => Navigator.pop(context, _ViewerAction.delete),
              ),
            ],
          ),
          const Divider(height: 28),
          if (memo.markdown.trim().isNotEmpty)
            MarkdownBody(
              data: memo.markdown,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(p: theme.textTheme.bodyLarge),
            ),
          if (memo.images.isNotEmpty) ...[
            const SizedBox(height: 20),
            _ImageStrip(
              files: [for (final name in memo.images) MemoStore.instance.imageFile(record.id, name)],
            ),
          ],
          if (memo.location != null) ...[
            const SizedBox(height: 12),
            _LocationTile(location: memo.location!),
          ],
          const SizedBox(height: 20),
          Text(
            tr("마지막 수정: ", "Last edited: ") + DateFormat(tr('yyyy. M. d. HH:mm', 'MMM d, yyyy HH:mm'), AppLocale.intl).format(memo.updatedAt),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// 위치 표시 (저장 기능은 추후 추가 예정. 형식만 미리 맞춰 둠)
class _LocationTile extends StatelessWidget {
  final MemoLocation location;

  const _LocationTile({required this.location});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.place_rounded, color: Colors.redAccent),
      title: Text(location.label ?? location.coordinateText),
      subtitle: location.label != null ? Text(location.coordinateText) : null,
    );
  }
}

/// 첨부 사진 가로 목록. 탭하면 전체 화면으로 보기
class _ImageStrip extends StatelessWidget {
  final List<File> files;
  final ValueChanged<int>? onRemove;

  const _ImageStrip({required this.files, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) => Stack(
          children: [
            GestureDetector(
              onTap: () => _openFullScreen(context, i),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  files[i],
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  cacheWidth: 360,
                  errorBuilder: (_, _, _) => Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey.withValues(alpha: 0.2),
                    child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                  ),
                ),
              ),
            ),
            if (onRemove != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => onRemove!(i),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close_rounded, size: 16, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openFullScreen(BuildContext context, int initial) {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
        body: PageView.builder(
          controller: PageController(initialPage: initial),
          itemCount: files.length,
          itemBuilder: (_, i) => InteractiveViewer(
            maxScale: 5,
            child: Center(child: Image.file(files[i])),
          ),
        ),
      ),
    ));
  }
}

// ==========================================
// 작성/수정 모달
// ==========================================
class _MemoEditor extends StatefulWidget {
  final CustomDataRecord record;
  final CustomDataType type;
  final RecordMemo? memo;
  final String initialText;

  const _MemoEditor({required this.record, required this.type, required this.memo, required this.initialText});

  @override
  State<_MemoEditor> createState() => _MemoEditorState();
}

class _MemoEditorState extends State<_MemoEditor> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialText);
  final FocusNode _focus = FocusNode();
  late final List<String> _keptImages = [...?widget.memo?.images]; // 기존 첨부 (파일 이름)
  final List<String> _newImages = []; // 새로 고른 사진 (갤러리 경로)
  bool _preview = false;
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (!_dirty && _controller.text != widget.initialText) setState(() => _dirty = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final picked = await ImagePicker().pickMultiImage(maxWidth: 2048, maxHeight: 2048, imageQuality: 85);
      if (picked.isEmpty || !mounted) return;
      setState(() {
        _newImages.addAll(picked.map((x) => x.path));
        _dirty = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(tr("사진을 불러오지 못했습니다: $e", "Couldn't load photos: $e"))),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _keptImages.length) {
        _keptImages.removeAt(index);
      } else {
        _newImages.removeAt(index - _keptImages.length);
      }
      _dirty = true;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await MemoStore.instance.save(
        recordId: widget.record.id,
        markdown: _controller.text,
        keepImages: _keptImages,
        newImages: _newImages,
        location: widget.memo?.location,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(tr("메모를 저장하지 못했습니다: $e", "Couldn't save the memo: $e"))),
      );
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(tr("작성 중인 내용을 버릴까요?", "Discard your changes?")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr("계속 작성", "Keep editing"))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr("버리기", "Discard"), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    return ok == true;
  }

  // ---------- 마크다운 입력 도우미 ----------
  /// 선택한 글자를 [left]/[right]로 감쌈 (선택이 없으면 커서 위치에 넣고 가운데에 커서)
  void _wrap(String left, String right) {
    final text = _controller.text;
    final sel = _controller.selection.isValid ? _controller.selection : TextSelection.collapsed(offset: text.length);
    final selected = sel.textInside(text);
    _controller.value = TextEditingValue(
      text: text.replaceRange(sel.start, sel.end, '$left$selected$right'),
      selection: selected.isEmpty
          ? TextSelection.collapsed(offset: sel.start + left.length)
          : TextSelection(baseOffset: sel.start + left.length, extentOffset: sel.start + left.length + selected.length),
    );
    _focus.requestFocus();
  }

  /// 커서가 있는 줄 앞에 [prefix]를 붙임 (이미 있으면 뗌)
  void _toggleLinePrefix(String prefix) {
    final text = _controller.text;
    final int cursor = _controller.selection.isValid ? _controller.selection.start : text.length;
    final int lineStart = cursor == 0 ? 0 : text.lastIndexOf('\n', cursor - 1) + 1;
    final bool has = text.startsWith(prefix, lineStart);
    _controller.value = TextEditingValue(
      text: has ? text.replaceRange(lineStart, lineStart + prefix.length, '') : text.replaceRange(lineStart, lineStart, prefix),
      selection: TextSelection.collapsed(offset: has ? cursor - prefix.length : cursor + prefix.length),
    );
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final images = [
      for (final name in _keptImages) MemoStore.instance.imageFile(widget.record.id, name),
      for (final path in _newImages) File(path),
    ];

    return PopScope(
      canPop: !_dirty || _saving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && context.mounted) Navigator.pop(context, false);
      },
      child: Padding(
        // 키보드가 올라오면 그만큼 위로
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SizedBox(
          // 키보드가 올라와도 모달이 화면 밖으로 넘치지 않도록 남은 높이에 맞춤
          height: math.min(MediaQuery.sizeOf(context).height * 0.85,
              MediaQuery.sizeOf(context).height - MediaQuery.viewInsetsOf(context).bottom - 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MemoHeader(
                  record: widget.record,
                  type: widget.type,
                  actions: [
                    IconButton(
                      tooltip: tr("닫기", "Close"),
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(value: false, label: Text(tr("작성", "Write")), icon: const Icon(Icons.edit_note_rounded)),
                        ButtonSegment(value: true, label: Text(tr("미리보기", "Preview")), icon: const Icon(Icons.visibility_outlined)),
                      ],
                      selected: {_preview},
                      onSelectionChanged: (v) => setState(() => _preview = v.first),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: tr("사진 추가", "Add photos"),
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      onPressed: _pickImages,
                    ),
                  ],
                ),
                if (!_preview)
                  // 자주 쓰는 마크다운 문법 바로 넣기
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _toolButton(Icons.format_bold_rounded, tr("굵게", "Bold"), () => _wrap('**', '**')),
                        _toolButton(Icons.format_italic_rounded, tr("기울임", "Italic"), () => _wrap('*', '*')),
                        _toolButton(Icons.title_rounded, tr("제목", "Heading"), () => _toggleLinePrefix('## ')),
                        _toolButton(Icons.format_list_bulleted_rounded, tr("목록", "List"), () => _toggleLinePrefix('- ')),
                        _toolButton(Icons.check_box_outlined, tr("체크리스트", "Checklist"), () => _toggleLinePrefix('- [ ] ')),
                        _toolButton(Icons.format_quote_rounded, tr("인용", "Quote"), () => _toggleLinePrefix('> ')),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: _preview
                      ? SingleChildScrollView(
                          child: _controller.text.trim().isEmpty
                              ? Text(tr("작성한 내용이 없습니다.", "Nothing written yet."), style: const TextStyle(color: Colors.grey))
                              : MarkdownBody(
                                  data: _controller.text,
                                  styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(p: theme.textTheme.bodyLarge),
                                ),
                        )
                      : TextField(
                          controller: _controller,
                          focusNode: _focus,
                          autofocus: widget.initialText.isEmpty,
                          expands: true,
                          maxLines: null,
                          textAlignVertical: TextAlignVertical.top,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: tr("메모를 입력하세요. 마크다운을 지원합니다.\n예: **굵게**, ## 제목, - 목록, - [ ] 할 일",
                                "Write a memo. Markdown is supported.\ne.g. **bold**, ## Heading, - list, - [ ] to-do"),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                ),
                if (images.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _ImageStrip(files: images, onRemove: _removeImage),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(tr("저장", "Save"), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolButton(IconData icon, String tooltip, VoidCallback onPressed) =>
      IconButton(tooltip: tooltip, icon: Icon(icon, size: 22), visualDensity: VisualDensity.compact, onPressed: onPressed);
}
