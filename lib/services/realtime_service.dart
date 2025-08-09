import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RealtimeService {
  late final WebSocketChannel channel;

  RealtimeService() {
    // Ambil API_URL dari .env
    final apiUrl = dotenv.env['API_URL'];

    if (apiUrl == null) {
      throw Exception("API_URL tidak ditemukan di .env");
    }

    // Ubah dari http:// ke ws:// atau https:// ke wss://
    final wsUrl = apiUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');

    channel = WebSocketChannel.connect(Uri.parse('$wsUrl/realtime'));
  }

  Stream<dynamic> get stream => channel.stream;

  void dispose() {
    channel.sink.close();
  }
}
