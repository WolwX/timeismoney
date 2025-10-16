import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service pour synchroniser la date et l'heure avec un serveur externe.
class TimeSyncService {
  DateTime? _lastSyncedDateTime;

  /// URL d'une API publique pour l'heure (exemple : worldtimeapi.org)
  static const String _apiUrl = 'http://worldtimeapi.org/api/ip';

  /// Récupère la date et l'heure actuelles depuis le serveur.
  Future<DateTime?> fetchNetworkDateTime() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dateTimeStr = data['datetime'] as String?;
        if (dateTimeStr != null) {
          _lastSyncedDateTime = DateTime.parse(dateTimeStr);
          return _lastSyncedDateTime;
        }
      }
    } catch (e) {
      // Erreur réseau ou parsing
    }
    return null;
  }

  /// Retourne la dernière date/heure synchronisée (ou null si jamais synchronisé).
  DateTime? get lastSyncedDateTime => _lastSyncedDateTime;
}
