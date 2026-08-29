import 'package:flutter/material.dart';

import '../services/gemini_service.dart';
import '../theme/app_theme.dart';

class ApiSettingsScreen extends StatefulWidget {
  const ApiSettingsScreen({super.key});

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  final _controller = TextEditingController();
  final _service = GeminiService();
  bool _loading = true;
  bool _saving = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final key = await _service.getApiKey();
    if (!mounted) return;
    _controller.text = key ?? '';
    setState(() => _loading = false);
  }

  Future<void> _saveAndTest() async {
    if (_controller.text.trim().isEmpty) {
      _show('សូមបញ្ចូល Gemini API Key');
      return;
    }

    setState(() => _saving = true);
    try {
      await _service.saveApiKey(_controller.text);
      final ok = await _service.testConnection();
      if (!mounted) return;
      _show(ok ? 'ភ្ជាប់ Gemini API បានជោគជ័យ ✅' : 'រក្សាទុក Key រួច ប៉ុន្តែ Test មិនជោគជ័យ');
    } catch (e) {
      if (!mounted) return;
      _show('API Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeKey() async {
    await _service.deleteApiKey();
    _controller.clear();
    if (!mounted) return;
    _show('បានលុប API Key ចេញពីឧបករណ៍');
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
          'Gemini API Settings',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.key_rounded, color: AppTheme.pink),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Gemini API Key',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Key នេះត្រូវបានរក្សាទុកក្នុង secure storage លើទូរស័ព្ទរបស់អ្នក។ វាមិនត្រូវបានបញ្ចូលទៅ GitHub ឬ APK ទេ។',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _controller,
                          obscureText: _obscure,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            labelText: 'Paste API Key',
                            hintText: 'AIza…',
                            filled: true,
                            fillColor: const Color(0xFF10141B),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: _saving ? null : _saveAndTest,
                            icon: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.cloud_done_rounded),
                            label: Text(
                              _saving ? 'កំពុង Test…' : 'Save & Test API',
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.pink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: _saving ? null : _removeKey,
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Remove API Key'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Model: Gemini 3.7 Flash\nប្រើសម្រាប់ Subtitle / Script translation ក្នុង PINKA Ai។',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
