import 'package:dart_frog/dart_frog.dart';

/// Route handler for /auth endpoint
/// 
/// This catches requests to /auth without a specific sub-route
/// and returns a list of available auth endpoints.
Response onRequest(RequestContext context) {
  return Response(
    statusCode: 200,
    body: '''{
  "endpoints": [
    "POST /auth/register",
    "POST /auth/signin",
    "POST /auth/refresh-token"
  ]
}''',
  );
}