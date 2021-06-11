// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:async';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_todos/models/todo_entity.dart';
import 'package:http/http.dart' as http;

/// A class that is meant to represent a Client that would be used to call a Web
/// Service. It is responsible for fetching and persisting Todos to and from the
/// cloud.
///
/// Since we're trying to keep this example simple, it doesn't communicate with
/// a real server but simply emulates the functionality.
class WebClient {
  final Duration delay;

  const WebClient([this.delay = const Duration(milliseconds: 3000)]);
  static const storage = FlutterSecureStorage();
  static const SERVER_ADDRESS = 'http://159.65.166.225:80';
  Future<List<TodoEntity>> fetchTodos() async {
    //get token
    String token = await getToken();
    var res = await http.get(Uri.parse('$SERVER_ADDRESS/api/v1/todos'),
        headers: <String, String>{'Authorization': 'Bearer $token'});
    print(res.body);
    var payload = jsonDecode(res.body);
    if (payload['success'] == true) {
      final todos = (payload['data'])
          .map<TodoEntity>((todo) => TodoEntity.fromJson(todo))
          .toList();

      return todos;
    }
  }

  Future<SuccessAndTodoEntity> postTodo(TodoEntity todo) async {
    try{
    //get token
    String token = await getToken();
    var res = await http.post(Uri.parse('$SERVER_ADDRESS/api/v1/todos'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      body: jsonEncode(todo.toJson())
        );
    if (res.statusCode == 201){
      var payload = jsonDecode(res.body);
      if (payload['success']==true){
        final todo = TodoEntity.fromJson(payload['data']);
        print(todo.toString());
        return SuccessAndTodoEntity(true, todoEntity: todo);
      }
    }
    return SuccessAndTodoEntity(false);}
    catch (e){
      print(e);
      throw e;
    }

  }

  Future<SuccessAndTodoEntity> updateTodo(TodoEntity todo) async {
    try{
      //get token
      String token = await getToken();
      var res = await http.put(Uri.parse('$SERVER_ADDRESS/api/v1/todos/${todo.id}'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(todo.toJson())
      );
      if (res.statusCode == 200){
        var payload = jsonDecode(res.body);
        if (payload['success']==true){
          final todo = TodoEntity.fromJson(payload['data']);
          print(todo.toString());
          return SuccessAndTodoEntity(true, todoEntity: todo);
        }
      }
      return SuccessAndTodoEntity(false);}
    catch (e){
      print(e);
      throw e;
    }

  }

  Future<String> getToken() async {
    try {
      String token = await storage.read(key: 'token');
      return token;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  /// Mock that "fetches" some Todos from a "web service" after a short delay
  // Future<List<TodoEntity>> fetchTodosOriginal() async {
  //   return Future.delayed(
  //       delay,
  //       () => [
  //             TodoEntity(
  //               'Buy food for da kitty',
  //               '1',
  //               'With the chickeny bits!',
  //               false,
  //             ),
  //             TodoEntity(
  //               'Find a Red Sea dive trip',
  //               '2',
  //               'Echo vs MY Dream',
  //               false,
  //             ),
  //             TodoEntity(
  //               'Book flights to Egypt',
  //               '3',
  //               '',
  //               true,
  //             ),
  //             TodoEntity(
  //               'Decide on accommodation',
  //               '4',
  //               '',
  //               false,
  //             ),
  //             TodoEntity(
  //               'Sip Margaritas',
  //               '5',
  //               'on the beach',
  //               true,
  //             ),
  //           ]);
  // }

  /// Mock that returns true or false for success or failure. In this case,
  /// it will "Always Succeed"
  Future<bool> postTodos(List<TodoEntity> todos) async {
    return Future.value(true);
  }


}

class SuccessAndTodoEntity {
  final bool success;
  final TodoEntity todoEntity;

  SuccessAndTodoEntity(this.success, {this.todoEntity});
}
