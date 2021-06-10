import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

enum AuthenticationStatus { unknown, authenticated, unauthenticated, authenticationFailure }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();
  final storage = FlutterSecureStorage();
  static const SERVER_ADDRESS = 'http://159.65.166.225:80';

  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<bool> logIn({
    required String username,
    required String password,
  }) async {
    try{
    var res = await http.post(
      Uri.parse('$SERVER_ADDRESS/api/v1/auth/login'),
      headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String,String>{
        "email": username,
        "password": password
      })
    );
    print(res.body);
    print(res.statusCode);
    if (res.statusCode == 200) {
      var payload = jsonDecode(res.body);
      if (payload['success']==true){
        //Store the token
        storage.write(key:'token',value: payload['token']);
        _controller.add(AuthenticationStatus.authenticated);
        return true;
      }
    } else{
      return false;

    }
    }
    catch (e){
      print(e);
      _controller.addError(e);
      _controller.add(AuthenticationStatus.unauthenticated);
    }
    return false;
  }

  void logOut() {
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}
