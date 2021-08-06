import 'package:ml_facedetection/models/recognition_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/status.dart' as status;

class StreamingService {
  late WebSocketChannel _channel ;

  Future Function(RecognizedFace recognizedFace) onServerFeedback;

  var ws_address = 'ws://192.168.1.76:8081/ws/';

  set send(content) {

    _channel.sink.add(content);
  }

  StreamingService(this.onServerFeedback) {
    _channel = WebSocketChannel.connect(
      Uri.parse(ws_address),
    );

    _channel.stream.listen((event) {
      print('received data');
      print(event);
    }, onError: (error) {
      print('received error');
    }, onDone: () {
      print('onDone ');
    }, cancelOnError: true);
  }

  void dispose() {
    _channel.sink.close(0, 'closed intentionally');
  }
}
