import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/gemini_service.dart';
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
  final _gemini = GeminiService();
  PlatformFile? _video;
  PlatformFile? _subtitle;
  bool _hasApiKey = false;

  @override
  void initState() {
    super.initState();
    _refreshApiStatus();
  }

  Future<void> _refreshApiStatus() async {
    final hasKey = await _gemini.hasApiKey();
    if (mounted) setState(() => _hasApiKey = hasKey);
  }

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

  Future<void> _openApiSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ApiSettingsScreen()),
    );
    await _refreshApiStatus();
  }

  void _continue() {
    if (_video == null && _subtitle == null) return;
    if (!_hasApiKey) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('សូមដាក់ Gemini API Key នៅ Settings ជាមុនសិន')),
      );
      _openApiSettings();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkspaceScreen(video: _video, subtitle: _subtitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = (_video != null || _subtitle != null) && _hasApiKey;
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
                  const Text(
                    'បកប្រែសំឡេង',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ជាកម្មវិធីសម្រាប់បកប្រែវីដេអូដោយប្រើប្រាស់ AI របស់ Google GEMINI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 26),
                  StepCard(
                    step: 'ជំហាន 1',
                    title: 'វីដេអូ',
                    subtitle: 'ជ្រើសរើសវីដេអូដែលអ្នកចង់បកប្រែ',
                    icon: Icons.video_library_outlined,
                    selected: _video != null,
                    fileName: _video?.name,
                    onTap: _pickVideo,
                  ),
                  const SizedBox(height: 18),
                  StepCard(
                    step: 'ជំហាន 2',
                    title: 'ចំណងជើង',
                    subtitle: 'បញ្ចូល .srt / .vtt / .txt ឬបន្តទៅ Workspace',
                    icon: Icons.subtitles_outlined,
                    selected: _subtitle != null,
                    fileName: _subtitle?.name,
                    onTap: _pickSubtitle,
                  ),
                  const SizedBox(height: 18),
                  InkWell(
                    onTap: _openApiSettings,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: _hasApiKey ? AppTheme.pink : AppTheme.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B202A),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.settings_rounded,
                              color: AppTheme.pinkSoft,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'API Settings',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _hasApiKey
                                      ? 'Gemini API Key បានដាក់រួច ✓'
                                      : 'ចុចទីនេះដើម្បីដាក់ Gemini API Key',
                                  style: TextStyle(
                                    color: _hasApiKey
                                        ? AppTheme.pinkSoft
                                        : AppTheme.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppTheme.textSecondary,
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    height: 62,
                    child: FilledButton.icon(
                      onPressed: ready ? _continue : null,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text(
                        'ចូលទៅការបកប្រែ',
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
                      Icon(Icons.auto_awesome_rounded, size: 17, color: AppTheme.pink),
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
