import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WorkspaceScreen extends StatefulWidget {
  final PlatformFile? video;
  final PlatformFile? subtitle;
  const WorkspaceScreen({super.key, this.video, this.subtitle});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  late final TextEditingController _controller;
  String _language = 'Khmer';

  @override
  void initState() {
    super.initState();
    var text = '';
    final bytes = widget.subtitle?.bytes;
    if (bytes != null) text = utf8.decode(bytes, allowMalformed: true);
    _controller = TextEditingController(text: text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showNotice() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF151922),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.auto_awesome_rounded, color: AppTheme.pink), SizedBox(width: 10), Text('PINKA Ai', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800))]),
          const SizedBox(height: 14),
          const Text('Version 1 មាន UI, file picker និង subtitle workspace។ មុខងារ AI translation/voice ត្រូវភ្ជាប់ API ឬ backend បន្ថែម។', style: TextStyle(color: AppTheme.textSecondary, height: 1.5)),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('យល់ព្រម'))),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PINKA Ai Workspace', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            if (widget.video != null) _InfoTile(icon: Icons.movie_creation_outlined, title: 'Video', value: widget.video!.name),
            if (widget.video != null) const SizedBox(height: 12),
            if (widget.subtitle != null) _InfoTile(icon: Icons.subtitles_outlined, title: 'Subtitle', value: widget.subtitle!.name),
            if (widget.subtitle != null) const SizedBox(height: 18),
            _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ភាសាគោលដៅ', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _language,
                dropdownColor: const Color(0xFF1A1F28),
                decoration: const InputDecoration(filled: true, fillColor: Color(0xFF1A1F28), border: OutlineInputBorder(borderSide: BorderSide.none)),
                items: const ['Khmer', 'English', 'Chinese', 'Thai', 'Vietnamese'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) => setState(() => _language = value ?? 'Khmer'),
              ),
            ])),
            const SizedBox(height: 18),
            _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Subtitle / Script', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(controller: _controller, minLines: 10, maxLines: 18, decoration: const InputDecoration(hintText: 'បញ្ចូល subtitle ឬ script នៅទីនេះ…', filled: true, fillColor: Color(0xFF10141B), border: OutlineInputBorder(borderSide: BorderSide.none))),
            ])),
            const SizedBox(height: 20),
            SizedBox(height: 58, child: FilledButton.icon(onPressed: _showNotice, icon: const Icon(Icons.auto_awesome_rounded), label: Text('បកប្រែទៅ $_language', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)), style: FilledButton.styleFrom(backgroundColor: AppTheme.pink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))))),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppTheme.cardBorder)), child: child);
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoTile({required this.icon, required this.title, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.cardBorder)),
    child: Row(children: [Icon(icon, color: AppTheme.pink), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)), const SizedBox(height: 3), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))]))]),
  );
}
