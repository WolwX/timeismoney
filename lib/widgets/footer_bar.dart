import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart' show rootBundle;

/// FooterBar used across screens to display credits and version.
class FooterBar extends StatefulWidget implements PreferredSizeWidget {
  final String creatorName;
  final String? version;
  final VoidCallback? onCreatorTap;
  final bool minimal;

  const FooterBar({
    Key? key,
    required this.creatorName,
    this.version,
    this.onCreatorTap,
    this.minimal = false,
  }) : super(key: key);
  @override
  State<FooterBar> createState() => _FooterBarState();

  @override
  Size get preferredSize => const Size.fromHeight(36);
}
class _FooterBarState extends State<FooterBar> {
  String? _versionLabel;

  @override
  void initState() {
    super.initState();
    _initPackageInfoIfNeeded();
  }

  Future<void> _initPackageInfoIfNeeded() async {
    // Priority 1: widget.version provided explicitly
    if (widget.version != null && widget.version!.isNotEmpty) {
      setState(() => _versionLabel = widget.version);
      return;
    }
    // Priority 2: try to read pubspec.yaml from assets (must be declared in pubspec.yaml)
    try {
      final rawPubspec = await rootBundle.loadString('pubspec.yaml');
      final lines = rawPubspec.split('\n');
      final versionLine = lines.firstWhere((l) => l.trim().startsWith('version:'), orElse: () => '');
      if (versionLine.isNotEmpty) {
        final parts = versionLine.split(':');
        if (parts.length > 1) {
          final ver = parts.sublist(1).join(':').trim();
          // ver could be like '1.1.3+45' -> parse major.minor
          final core = ver.split('+')[0];
              final p = core.split('.');
              final major = p.isNotEmpty ? p[0] : '0';
              final minor = p.length > 1 ? p[1] : '0';
              final build = ver.contains('+') ? ver.split('+')[1] : null;
          final now = DateTime.now();
          final dd = now.day.toString().padLeft(2, '0');
          final mm = now.month.toString().padLeft(2, '0');
          final yy = (now.year % 100).toString().padLeft(2, '0');
              setState(() {
                if (build != null && build.isNotEmpty && build != '$dd$mm$yy') {
                  _versionLabel = 'v$major.$minor.$dd$mm$yy+$build';
                } else {
                  _versionLabel = 'v$major.$minor.$dd$mm$yy';
                }
              });
          return;
        }
      }
    } catch (_) {
      // fall through to package_info fallback
    }
    try {
      final info = await PackageInfo.fromPlatform();
      final raw = info.version.trim();
      // build date in French format dd MM yy
      final now = DateTime.now();
      final dd = now.day.toString().padLeft(2, '0');
      final mm = now.month.toString().padLeft(2, '0');
      final yy = (now.year % 100).toString().padLeft(2, '0');
      if (raw.isNotEmpty) {
        // parse major.minor and build from package version
        final core = raw.split('+')[0];
        final parts = core.split('.');
        final major = parts.isNotEmpty ? parts[0] : '0';
        final minor = parts.length > 1 ? parts[1] : '0';
        final build = info.buildNumber.isNotEmpty ? info.buildNumber : null;
        if (build != null && build.isNotEmpty && build != '$dd$mm$yy') {
          setState(() => _versionLabel = 'v$major.$minor.$dd$mm$yy+$build');
        } else {
          setState(() => _versionLabel = 'v$major.$minor.$dd$mm$yy');
        }
      } else {
        setState(() => _versionLabel = 'v?.?.$dd$mm$yy');
      }
    } catch (_) {
      final now = DateTime.now();
      final dd = now.day.toString().padLeft(2, '0');
      final mm = now.month.toString().padLeft(2, '0');
      final yy = (now.year % 100).toString().padLeft(2, '0');
  setState(() => _versionLabel = 'v?.?$dd$mm$yy');
    }
  }



  @override
  Widget build(BuildContext context) {
    final versionToShow = _versionLabel ?? '...';
    if (widget.minimal) {
      return SizedBox(
        height: widget.preferredSize.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: widget.onCreatorTap,
                child: Row(
                  children: [
                    const Icon(Icons.code, size: 12, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(' ${widget.creatorName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
              Text(versionToShow, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    // Dark footer mode
    final bg = const Color(0xFF060608);
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: widget.preferredSize.height,
        decoration: BoxDecoration(
          color: bg,
          border: const Border(
            top: BorderSide(color: Color(0x22FFFFFF), width: 0.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: widget.onCreatorTap,
              child: Row(
                children: [
                  const Text('Créé par ', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.code, size: 12, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(widget.creatorName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
              child: Text(versionToShow, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}