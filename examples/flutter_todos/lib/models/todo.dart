import 'package:flutter_todos/models/todo_entity.dart';
import 'package:todos_app_core/todos_app_core.dart';
import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final bool complete;
  final String id;
  final String note;
  final String task;
  final DateTime createdAt;

  Todo(
    this.task, {
    this.complete = false,
    String note = '',
    String id,
        DateTime createdAt,
  })  : this.note = note ?? '',
        this.id = id ?? Uuid().generateV4(),
  this.createdAt = createdAt;

  Todo copyWith({bool complete, String id, String note, String task, DateTime createdAt}) {
    return Todo(
      task ?? this.task,
      complete: complete ?? this.complete,
      id: id ?? this.id,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt
    );
  }

  @override
  List<Object> get props => [complete, id, note, task, createdAt];

  @override
  String toString() {
    return 'Todo { complete: $complete, task: $task, note: $note, id: $id, createdAt $createdAt }';
  }

  TodoEntity toEntity() {
    return TodoEntity(task, id, note, complete, createdAt);
  }

  static Todo fromEntity(TodoEntity entity) {
    return Todo(
      entity.task,
      complete: entity.complete ?? false,
      note: entity.note,
      id: entity.id ?? Uuid().generateV4(),
      createdAt: entity.createdAt
    );
  }
}
