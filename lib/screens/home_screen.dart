import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/zip_service.dart';
import '../theme/glass_theme.dart';
import '../widgets/mini_app_tile.dart';
import '../widgets/glass_background.dart';
import '../widgets/glass_card.dart';
import 'webview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<MiniApp> _apps = [];
  bool _loading = true;
  bool _installing = false;
  late AnimationController _fabController;
  late Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
    _loadApps();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    final apps = await AppRegistry.loadAll();
    setState(() {
      _apps = apps;
      _loading = false;
    });
  }

  Future<void> _pickAndInstall() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;

    setState(() => _installing = true);
    try {
      final app = await ZipService.install(path);
      setState(() {
        _apps.add(app);
      });
      if (mounted) {
        _showSnack('"${app.name}" installed', success: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Failed to install: $e', success: false);
      }
    } finally {
      setState(() => _installing = false);
    }
  }

  Future<void> _deleteApp(MiniApp app) async {
    final confirmed = await showDialog<bool>(
          context: context,
          barrierColor: const Color(0x40000000),
          builder: (ctx) => _DeleteDialog(appName: app.name),
        ) ??
        false;
    if (!confirmed) return;
    await ZipService.uninstall(app);
    setState(() => _apps.removeWhere((a) => a.id == app.id));
    if (mounted) _showSnack('"${app.name}" removed');
  }

  void _showSnack(String msg, {bool? success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.sora(
              fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: success == true
            ? GlassTheme.successText
            : success == false
                ? GlassTheme.dangerText
                : GlassTheme.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openApp(MiniApp app) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => WebViewScreen(app: app),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlassTheme.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: _GlassAppBar(),
      ),
      body: GlassBackground(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: GlassTheme.accent,
                  strokeWidth: 2,
                ),
              )
            : _buildBody(),
      ),
      floatingActionButton: _installing
          ? _FabShell(
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              ),
            )
          : ScaleTransition(
              scale: _fabScale,
              child: GestureDetector(
                onTapDown: (_) => _fabController.forward(),
                onTapUp: (_) {
                  _fabController.reverse();
                  _pickAndInstall();
                },
                onTapCancel: () => _fabController.reverse(),
                child: _FabShell(
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (_apps.isEmpty) {
      return _EmptyState(onAdd: _pickAndInstall);
    }
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 84,
            left: 20,
            right: 20,
            bottom: 100,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final app = _apps[i];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 280 + i * 60),
                  curve: Curves.easeOut,
                  builder: (_, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, 14 * (1 - v)),
                      child: child,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: MiniAppTile(
                      app: app,
                      onTap: () => _openApp(app),
                      onDelete: () => _deleteApp(app),
                    ),
                  ),
                );
              },
              childCount: _apps.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// FAB Shell
// ─────────────────────────────────────────────────────────
class _FabShell extends StatelessWidget {
  final Widget child;
  const _FabShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: GlassTheme.accent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          // Specular white on top edge
          BoxShadow(
            color: Color(0x40FFFFFF),
            blurRadius: 0,
            offset: Offset(0, 1),
          ),
          // Soft outer shadow
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Blurred App Bar
// ─────────────────────────────────────────────────────────
class _GlassAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: GlassTheme.glassPanel(),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                children: [
                  Text('My Apps', style: GlassTheme.pageTitle),
                  const Spacer(),
                  // Ghost pill badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: GlassTheme.ghostPill(radius: 20),
                    child: Text(
                      'MINI-APP HOST',
                      style: GlassTheme.labelXs.copyWith(letterSpacing: 0.14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glass icon container
            GlassCard(
              radius: 22,
              sigma: 20,
              child: Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.widgets_outlined,
                  size: 34,
                  color: GlassTheme.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No mini-apps yet',
              style: GlassTheme.sectionHeading
                  .copyWith(color: GlassTheme.textMuted),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to upload a ZIP file and install your first mini-app.',
              textAlign: TextAlign.center,
              style: GlassTheme.metaText,
            ),
            const SizedBox(height: 28),
            // Ghost pill button
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  color: GlassTheme.accent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x30000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Add Mini-App',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Delete Dialog
// ─────────────────────────────────────────────────────────
class _DeleteDialog extends StatelessWidget {
  final String appName;
  const _DeleteDialog({required this.appName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xE8FFFFFF),
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: const Color(0xBFFFFFFF), width: 1.2),
              boxShadow: const [
                BoxShadow(
                    color: Color(0xBBFFFFFF),
                    blurRadius: 0,
                    offset: Offset(0, 1)),
                BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 40,
                    offset: Offset(0, 12)),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Remove App', style: GlassTheme.cardTitle),
                const SizedBox(height: 10),
                Text(
                  'Remove "$appName"? This will delete all its files.',
                  style:
                      GlassTheme.bodyText.copyWith(color: GlassTheme.textMuted),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0x0A000000),
                            border: Border.all(
                                color: const Color(0xBFFFFFFF), width: 1.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text('Cancel', style: GlassTheme.bodyText),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: GlassTheme.dangerBg,
                            border: Border.all(
                                color: GlassTheme.dangerText.withOpacity(0.3),
                                width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Remove',
                            style: GlassTheme.bodyText
                                .copyWith(color: GlassTheme.dangerText),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
