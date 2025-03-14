import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:convert';
import 'template.dart';

extension type Headers._(JSObject _) implements JSObject {
  external factory Headers();
  external void append(String name, String value);
  external String get(String name);
}

extension type ResponseInit._(JSObject _) implements JSObject {
  external factory ResponseInit({
    int? status,
    String? statusText,
    Headers? headers,
    WebSocket? webSocket,
  });
}

extension type Request._(JSObject _) implements JSObject {
  external String get url;
  external Headers get headers;
}

extension type Response._(JSObject _) implements JSObject {
  external factory Response(String? body, [ResponseInit? init]);
  // external factory Response.status(String url, int status);
}

extension type FetchEvent._(JSObject _) implements JSObject {
  external Request get request;
  // Accept either Response or Future<Response> (as JSPromise)
  external void respondWith(JSAny r);
}

extension type WebSocketPair._(JSObject _) implements JSObject {
  external factory WebSocketPair();

  WebSocket get client => this.getProperty("0".toJS);
  WebSocket get server => this.getProperty("1".toJS);
}

extension type WsEvent._(JSObject _) implements JSObject {
  external String get data;
}

extension type WebSocket._(JSObject _) implements JSObject {
  external void accept();
  // external void close({int code, String reason});
  @JS('send')
  external void sendString(String message);
  // @JS('send')
  // external void sendArrayBuffer(ArrayBuffer buffer);
  // @JS('send')
  // external void sendUint8List(Uint8List buffer);

  external void addEventListener(String message, JSFunction callback);
}

@JS()
external void addEventListener(String type, JSFunction callback);

Response handleRequest(Request request) {
  var uri = Uri.parse(request.url);
  switch (uri.path) {
    case "/":
      return new Response(
          template,
          ResponseInit(
              status: 200,
              headers: Headers()..append("Content-Type", "text/html")));
    case "/ws":
      return handleWebSocket(request);
    default:
      return new Response("Not found", ResponseInit(status: 404));
  }
}

void handleSession(WebSocket websocket) {
  websocket.accept();
  websocket.addEventListener(
      "message",
      ((event) {
        if (event.data == "CLICK") {
          // count += 1
          websocket.sendString(jsonEncode({
            "count": 1,
            "tz": DateTime.now(),
          }));
        } else {
          // An unknown message came into the server. Send back an error message
          websocket.sendString(jsonEncode({
            "error": "Unknown message received",
          }));
        }
      }).toJS);

  websocket.addEventListener(
      "close",
      ((event) {
        // Handle when a client closes the WebSocket connection
        print(event);
      }).toJS);
}

Response handleWebSocket(Request request) {
  var upgradeHeader = request.headers.get("Upgrade");
  print(upgradeHeader);
  if (upgradeHeader != "websocket") {
    return new Response("Expected websocket", ResponseInit(status: 400));
  }

  var ws = WebSocketPair();
  var server = ws.server;
  var client = ws.client;
  handleSession(server);
  return new Response(null, ResponseInit(status: 101, webSocket: client));
}

Future<void> main() async {
  addEventListener(
      'fetch',
      ((FetchEvent event) {
        event.respondWith(handleRequest(event.request));
      }).toJS);
}
