import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart' show rootBundle;

/// FooterBar used across screens to display credits and version.
class FooterBar extends StatefulWidget implements PreferredSizeWidget {
  final String creatorName;
  final String? version;
  final VoidCallback? onCreatorTap;
  final bool minimal;
  /// Si true, n'affiche que la version majeure (ex: 1.4)
  final bool majorOnly;

  const FooterBar({
    Key? key,
    required this.creatorName,
    this.version,
    this.onCreatorTap,
    this.minimal = false,
    this.majorOnly = false,
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
          // ver est du type '1.4.0+151025'
          String versionLabel;
          if (widget.majorOnly) {
            // On ne garde que les deux premiers segments (majeur.mineur)
            final mainParts = ver.split('.');
            if (mainParts.length >= 2) {
              versionLabel = 'v${mainParts[0]}.${mainParts[1]}';
            } else {
              versionLabel = 'v$ver';
            }
          } else {
            final fullVersion = ver.replaceAll('+', '.');
            versionLabel = 'v$fullVersion';
          }
          setState(() {
            _versionLabel = versionLabel;
          });
          return;
        }
      }
    } catch (_) {
      // fall through to package_info fallback
    }
    
    // Priority 3: use PackageInfo.fromPlatform()
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version.trim();
      final buildNumber = info.buildNumber.trim();
      if (version.isNotEmpty) {
        String versionLabel;
        if (widget.majorOnly) {
          final mainParts = version.split('.');
          if (mainParts.length >= 2) {
            versionLabel = 'v${mainParts[0]}.${mainParts[1]}';
          } else {
            versionLabel = 'v$version';
          }
        } else if (buildNumber.isNotEmpty && buildNumber != '0') {
          versionLabel = 'v$version.$buildNumber';
        } else {
          versionLabel = 'v$version';
        }
        setState(() => _versionLabel = versionLabel);
      } else {
        setState(() => _versionLabel = 'v?.?.?');
      }
    } catch (_) {
      setState(() => _versionLabel = 'v?.?.?');
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