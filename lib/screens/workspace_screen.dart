import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/gemini_service.dart';
import '../theme/app_theme.dart';
import 'api_settings_screen.dart';

class WorkspaceScreen extends StatefulWidget {
  final PlatformFile? video;
  final PlatformFile? subtitle;

  const WorkspaceScreen({super.key, this.video, this.subtitle});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  late final TextEditingController _controller;
  final _gemini = GeminiService();
  String _language = 'Khmer';
  bool _translating = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadSubtitle();
  }

  Future<void> _loadSubtitle() async {
    final file = widget.subtitle;
    if (file == null) return;
    try {
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      _controller.text = utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('មិនអាចអាន Subtitle បានទេ')),
      );
    }
  }

  Future<void> _openApiSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ApiSettingsScreen()),
    );
  }

  Future<void> _translate() async {
    if (_controller.text.trim().isEmpty) {
      _show('សូមបញ្ចូល Subtitle ឬ Script ជាមុនសិន');
      return;
    }

    if (!await _gemini.hasApiKey()) {
      if (!mounted) return;
      _show('សូមដាក់ Gemini API Key ជាមុនសិន');
      await _openApiSettings();
      return;
    }

    setState(() => _translating = true);
    try {
      final translated = await _gemini.translateSubtitle(
        text: _controller.text,
        targetLanguage: _language,
      );
      if (!mounted) return;
      _controller.text = translated;
      _show('បកប្រែទៅ $_language បានជោគជ័យ ✅');
    } catch (e) {
      if (!mounted) return;
      _show('Translate Error: $e');
    } finally {
      if (mounted) setState(() => _translating = false);
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PINKA Ai Workspace',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Gemini API Settings',
            onPressed: _translating ? null : _openApiSettings,
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            if (widget.video != null)
              _InfoTile(
                icon: Icons.movie_creation_outlined,
                title: 'Video',
                value: widget.video!.name,
              ),
            if (widget.video != null) const SizedBox(height: 12),
            if (widget.subtitle != null)
              _InfoTile(
                icon: Icons.subtitles_outlined,
                title: 'Subtitle',
                value: widget.subtitle!.name,
              ),
            if (widget.subtitle != null) const SizedBox(height: 18),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ភាសាគោលដៅ',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _language,
                    dropdownColor: const Color(0xFF1A1F28),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xFF1A1F28),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    items: const [
                      'Khmer',
                      'English',
                      'Chinese',
                      'Thai',
                      'Vietnamese',
                      'Japanese',
                      'Korean',
                      'French',
                      'Spanish',
                    ]
                        .map(
                          (e) => DropdownMenuItem(value: e, child: Text(e)),
                        )
                        .toList(),
                    onChanged: _translating
                        ? null
                        : (value) =>
                            setState(() => _language = value ?? 'Khmer'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subtitle / Script',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    minLines: 10,
                    maxLines: 18,
                    enabled: !_translating,
                    decoration: const InputDecoration(
                      hintText: 'បញ្ចូល subtitle ឬ script នៅទីនេះ…',
                      filled: true,
                      fillColor: Color(0xFF10141B),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 58,
              child: FilledButton.icon(
                onPressed: _translating ? null : _translate,
                icon: _translating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(
                  _translating ? 'កំពុងបកប្រែ…' : 'បកប្រែទៅ $_language',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'AI Translation • Gemini 3.7 Flash',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
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
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: child,
      );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.pink),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
