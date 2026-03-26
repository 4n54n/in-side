import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MiniApp {
  final String id;
  final String name;
  final String entryPath; // path to index.html
  final DateTime installedAt;

  const MiniApp({
    required this.id,
    required this.name,
    required this.entryPath,
    required this.installedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'entryPath': entryPath,
        'installedAt': installedAt.toIso8601String(),
      };

  factory MiniApp.fromJson(Map<String, dynamic> json) => MiniApp(
        id: json['id'] as String,
        name: json['name'] as String,
        entryPath: json['entryPath'] as String,
        installedAt: DateTime.parse(json['installedAt'] as String),
      );
}

class AppRegistry {
  static const _prefsKey = 'installed_mini_apps';

  static Future<List<MiniApp>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    return raw
        .map((s) => MiniApp.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> save(List<MiniApp> apps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      apps.map((a) => jsonEncode(a.toJson())).toList(),
    );
  }

  static Future<void> add(MiniApp app) async {
    final apps = await loadAll();
    apps.add(app);
    await save(apps);
  }

  static Future<void> remove(String id) async {
    final apps = await loadAll();
    apps.removeWhere((a) => a.id == id);
    await save(apps);
  }
}

class ZipService {
  static Future<Directory> get _appsDir async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/mini_apps');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  static Future<MiniApp> install(String zipPath) async {
    final zipFile = File(zipPath);
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final rawName = zipFile.uri.pathSegments.last.replaceAll('.zip', '');
    final id = '${rawName}_${DateTime.now().millisecondsSinceEpoch}';
    final appsDir = await _appsDir;
    final destDir = Directory('${appsDir.path}/$id');
    destDir.createSync(recursive: true);

    for (final file in archive) {
      final outPath = '${destDir.path}/${file.name}';
      if (file.isFile) {
        final outFile = File(outPath);
        outFile.createSync(recursive: true);
        outFile.writeAsBytesSync(file.content as List<int>);
      } else {
        Directory(outPath).createSync(recursive: true);
      }
    }

    // Find entry point
    String? entryPath;
    for (final file in archive) {
      if (file.name == 'index.html' || file.name.endsWith('/index.html')) {
        entryPath = '${destDir.path}/${file.name}';
        break;
      }
    }
    entryPath ??= '${destDir.path}/${archive.first.name}';

    final app = MiniApp(
      id: id,
      name: _prettifyName(rawName),
      entryPath: entryPath,
      installedAt: DateTime.now(),
    );
    await AppRegistry.add(app);
    return app;
  }

  static Future<void> uninstall(MiniApp app) async {
    final appsDir = await _appsDir;
    final dir = Directory('${appsDir.path}/${app.id}');
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    await AppRegistry.remove(app.id);
  }

  static String _prettifyName(String raw) {
    return raw
        .replaceAll(RegExp(r'[_\-]'), ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
