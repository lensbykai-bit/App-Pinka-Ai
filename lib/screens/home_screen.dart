import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/header_network.dart';
import '../widgets/step_card.dart';
import 'api_settings_screen.dart';
import 'workspace_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PlatformFile? _video;
  PlatformFile? _subtitle;

  Future<void> _pickVideo() async {
    final file = await FilePicker.pickFile(type: FileType.video);
    if (file != null && mounted) setState(() => _video = file);
  }

  Future<void> _pickSubtitle() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['srt', 'vtt', 'txt'],
    );
    if (file != null && mounted) setState(() => _subtitle = file);
  }

  void _continue() {
    if (_video == null && _subtitle == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkspaceScreen(video: _video, subtitle: _subtitle),
      ),
    );
  }

  Future<void> _openApiSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ApiSettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = _video != null || _subtitle != null;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: HeaderNetwork()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 38),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton.filledTonal(
                      tooltip: 'Gemini API Settings',
                      onPressed: _openApiSettings,
                      icon: const Icon(Icons.settings_rounded),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PINKA Ai',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.pinkSoft,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'AI Dubbing & Subtitle Workspace',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 28),
                  StepCard(
                    step: 'ជំហាន 1',
                    title: 'វីដេអូ',
                    subtitle: 'ជ្រើសរើសវីដេអូដែលអ្នកចង់ធ្វើការ',
                    icon: Icons.video_library_outlined,
                    selected: _video != null,
                    fileName: _video?.name,
                    onTap: _pickVideo,
                  ),
                  const SizedBox(height: 18),
                  StepCard(
                    step: 'ជំហាន 2',
                    title: 'Subtitle / Script',
                    subtitle: 'បញ្ចូល .srt / .vtt / .txt',
                    icon: Icons.subtitles_outlined,
                    selected: _subtitle != null,
                    fileName: _subtitle?.name,
                    onTap: _pickSubtitle,
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    height: 62,
                    child: FilledButton.icon(
                      onPressed: ready ? _continue : null,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text(
                        'ចូល Workspace',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.pink,
                        disabledBackgroundColor: const Color(0xFF2A2D34),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 17,
                        color: AppTheme.pink,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'PINKA Ai • Gemini Connected',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
