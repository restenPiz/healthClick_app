// lib/services/echo_service.dart

import 'package:laravel_echo/laravel_echo.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

late Echo echo;

void setupEcho() {
  IO.Socket socket = IO.io(
    'http://127.0.0.1:6001', // Ou IP da tua API Laravel com WebSocket
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect() // Não conecta automaticamente
        .build(),
  );

 echo = Echo(
    broadcaster: EchoBroadcasterType.SocketIO, // ✅ certo
    client: socket,
  );

  socket.connect(); // Agora conecta o socket
}
