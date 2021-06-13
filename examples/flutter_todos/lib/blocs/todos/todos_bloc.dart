import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_todos/blocs/todos/repository.dart';
import 'package:flutter_todos/blocs/todos/web_client.dart';
import 'package:meta/meta.dart';
import 'package:flutter_todos/blocs/todos/todos.dart';
import 'package:flutter_todos/models/models.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final TodosRepositoryFlutter todosRepository;

  TodosBloc({@required this.todosRepository}) : super(TodosLoadInProgress());

  @override
  Stream<TodosState> mapEventToState(TodosEvent event) async* {
    if (event is TodosLoaded) {
      yield* _mapTodosLoadedToState();
    } else if (event is TodoAdded) {
      yield* _mapTodoAddedToState(event);
    } else if (event is TodoUpdated) {
      yield* _mapTodoUpdatedToState(event);
    } else if (event is TodoDeleted) {
      yield* _mapTodoDeletedToState(event);
    } else if (event is ToggleAll) {
      yield* _mapToggleAllToState();
    } else if (event is ClearCompleted) {
      yield* _mapClearCompletedToState();
    } else if (event is TodosEmpty){
      yield* _mapTodosEmptyToState();
    }
  }

  Stream<TodosState> _mapTodosEmptyToState() async* {
    try {
      yield TodosLoadSuccess();
    } catch (_) {
      yield TodosLoadFailure();
    }
  }

  Stream<TodosState> _mapTodosLoadedToState() async* {
    try {
      final todos = await this.todosRepository.loadTodos();
      print(todos);
      yield TodosLoadSuccess(
        todos.map(Todo.fromEntity).toList()..sort((a,b)=>a.createdAt.compareTo(b.createdAt)),
      );
    } catch (e) {
      throw e;
      yield TodosLoadFailure();
    }
  }

  Stream<TodosState> _mapTodoAddedToState(TodoAdded event) async* {
    if (state is TodosLoadSuccess) {
      List<Todo> todosList = List.from((state as TodosLoadSuccess).todos);
      SuccessAndTodoEntity postSuccess = await todosRepository.postTodo(event.todo);
      if (postSuccess.success){
        List<Todo> updatedTodos = todosList;
        Todo newTodo = Todo.fromEntity(postSuccess.todoEntity);
        updatedTodos.add(newTodo);
        yield TodosLoadSuccess(updatedTodos);
      }else {
        yield TodosLoadFailure();
      }
      // _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapTodoUpdatedToState(TodoUpdated event) async* {
    if (state is TodosLoadSuccess) {
      List<Todo> todosList = List.from((state as TodosLoadSuccess).todos);
      SuccessAndTodoEntity updateSuccess = await todosRepository.updateTodo(event.todo);
      if (updateSuccess.success){
        List<Todo> updatedTodos = todosList..removeWhere((todo) => todo.id == event.todo.id);
        Todo newTodo = Todo.fromEntity(updateSuccess.todoEntity);
        updatedTodos.add(newTodo);
        updatedTodos.sort((a,b)=> a.createdAt.compareTo(b.createdAt));
        yield TodosLoadSuccess(updatedTodos);
      }else {
        yield TodosLoadFailure();
      }
    }
  }

  Stream<TodosState> _mapTodoDeletedToState(TodoDeleted event) async* {
    if (state is TodosLoadSuccess) {
      List<Todo> todosList = List.from((state as TodosLoadSuccess).todos);
      SuccessAndTodoEntity deleteSuccess = await todosRepository.deleteTodo(event.todo);
      if (deleteSuccess.success){
        List<Todo> updatedTodos = todosList..removeWhere((todo) => todo.id == event.todo.id);
        updatedTodos.sort((a,b)=> a.createdAt.compareTo(b.createdAt));
        yield TodosLoadSuccess(updatedTodos);
      }else {
        yield TodosLoadFailure();
      }
    }
  }

  Stream<TodosState> _mapToggleAllToState() async* {
    if (state is TodosLoadSuccess) {
      final allComplete =
          (state as TodosLoadSuccess).todos.every((todo) => todo.complete);
      final List<Todo> updatedTodos = (state as TodosLoadSuccess)
          .todos
          .map((todo) => todo.copyWith(complete: !allComplete))
          .toList();
      yield TodosLoadSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Stream<TodosState> _mapClearCompletedToState() async* {
    if (state is TodosLoadSuccess) {
      final List<Todo> updatedTodos = (state as TodosLoadSuccess)
          .todos
          .where((todo) => !todo.complete)
          .toList();
      yield TodosLoadSuccess(updatedTodos);
      _saveTodos(updatedTodos);
    }
  }

  Future _saveTodos(List<Todo> todos) {
    return todosRepository.saveTodos(
      todos.map((todo) => todo.toEntity()).toList(),
    );
  }
}
