import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(
    body: '''{
  "success": true,
  "message": "Campus Event API is healthy",
  "endpoints": ["/auth/register", "/auth/signin", "/auth/refresh-token"]
}''',
  );
}
