import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/zip_service.dart';
import '../theme/glass_theme.dart';
import 'glass_card.dart';

class MiniAppTile extends StatefulWidget {
  final MiniApp app;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const MiniAppTile({
    super.key,
    required this.app,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<MiniAppTile> createState() => _MiniAppTileState();
}

class _MiniAppTileState extends State<MiniAppTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  Color _avatarColor() {
    final colors = [
      const Color(0xFFC9A84C),
      const Color(0xFF9B6B9B),
      const Color(0xFF6B9B9B),
      const Color(0xFF9B7B6B),
      const Color(0xFF6B9B7B),
      const Color(0xFF9B6B7B),
    ];
    final hash = widget.app.id.codeUnits.fold(0, (v, c) => v + c);
    return colors[hash % 6];
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor();
    final initial =
        widget.app.name.isNotEmpty ? widget.app.name[0].toUpperCase() : '?';

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressController.reverse(),
        child: GlassCard(
          radius: 20,
          sigma: 28,
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Avatar — glass-styled
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Color.alphaBlend(
                            color.withOpacity(0.35), Colors.white),
                        width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: GoogleFonts.sora(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.app.name, style: GlassTheme.sectionHeading),
                    const SizedBox(height: 4),
                    Text(
                      'Installed ${_relativeDate(widget.app.installedAt)}',
                      style: GlassTheme.metaText,
                    ),
                  ],
                ),
              ),
              // 3-dot Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: GlassTheme.textSubtle, size: 22),
                color: GlassTheme.surfaceOpaque,
                elevation: 8,
                shadowColor: const Color(0x18000000),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                offset: const Offset(0, 40),
                onSelected: (value) {
                  if (value == 'uninstall') widget.onDelete();
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'uninstall',
                    child: Text(
                      'Uninstall',
                      style: GoogleFonts.sora(
                        color: GlassTheme.dangerText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
