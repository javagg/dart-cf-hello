import 'dart:js_interop';

@JS()
@staticInterop
class Request {
  external factory Request();
}

@JS()
@staticInterop
class Response {
  external factory Response(String body);
}

@JS()
@staticInterop
class FetchEvent {
  external factory FetchEvent();
}

extension FetchEventExtension on FetchEvent {
  external Request get request;
  external void respondWith(Response r);
}

@JS() 
@staticInterop
external void addEventListener(String type, JSFunction callback);

void main() {
    addEventListener('fetch', ((FetchEvent event) {
      event.respondWith(new Response("Dart Worker hello world!"));
    }).toJS);
}
