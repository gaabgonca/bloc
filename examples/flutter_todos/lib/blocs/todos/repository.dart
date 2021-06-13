// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:core';

import 'package:flutter_todos/models/models.dart';
import 'package:flutter_todos/models/todo_entity.dart';
import 'package:flutter_todos/todos%20repository/todos_repository.dart';
import 'package:meta/meta.dart';
import 'file_storage.dart';
import 'web_client.dart';

/// A class that glues together our local file storage and web client. It has a
/// clear responsibility: Load Todos and Persist todos.
class TodosRepositoryFlutter implements TodosRepository {
  final FileStorage fileStorage;
  final WebClient webClient;

  const TodosRepositoryFlutter({
    @required this.fileStorage,
    this.webClient =  const WebClient(),
  });

  /// Loads todos first from File storage. If they don't exist or encounter an
  /// error, it attempts to load the Todos from a Web Client.
  @override
  Future<List<TodoEntity>> loadTodos() async {
    try {
      // return await fileStorage.loadTodos();
      return await webClient.fetchTodos();
    } catch (e) {
      final todos = await webClient.fetchTodos();

      fileStorage.saveTodos(todos);

      return todos;
    }
  }

  Future<SuccessAndTodoEntity> postTodo(Todo todo) async {
    try {
      return await webClient.postTodo(todo.toEntity());
    } catch(e){
      throw e;
    }
  }

  Future<SuccessAndTodoEntity> updateTodo(Todo todo) async {
    try {
      return await webClient.updateTodo(todo.toEntity());
    } catch(e){
      throw e;
    }
  }

  Future<SuccessAndTodoEntity> deleteTodo(Todo todo) async {
    try {return await webClient.deleteTodo(todo.toEntity());}
    catch (e){
      throw e;
    }
  }

  // Persists todos to local disk and the web
  @override
  Future saveTodos(List<TodoEntity> todos) {
    return Future.wait<dynamic>([
      fileStorage.saveTodos(todos),
      webClient.postTodos(todos),
    ]);
  }
}
