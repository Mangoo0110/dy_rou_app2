//import 'dart:ffi';
//import 'dart:html';

import 'dart:async';

import 'package:dy_rou/crud/crud_exception.dart';
import 'package:dy_rou/extensions/filter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';

class TaskService {
  Database? _db;

  List<DatabaseTask> _tasks = [];

  DatabaseUser? _user;

  static final TaskService _shared = TaskService._sharedInstance();
  TaskService._sharedInstance() {
    _tasksStreamcontroller = StreamController<List<DatabaseTask>>.broadcast(
      onListen: () {
        _tasksStreamcontroller.sink.add(_tasks);
      },
    );
  }
  factory TaskService() => _shared;

  late final StreamController<List<DatabaseTask>> _tasksStreamcontroller;

  Stream<List<DatabaseTask>> get allTasks => _tasksStreamcontroller.stream.filter((task) {
    final currentUser =_user;
    if(currentUser!=null) {
      return task.userId == currentUser.id;
    } else {
      throw UserShouldBeSetBeforeReadingAllNotes();
    }
  });

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
   }) async {
    try {
      final user = await getUser(email: email);
      if(setAsCurrentUser){
        _user = user;
      }
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      if(setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _catcheTasks() async {
    final allTasks = await fetchAllTask();
    _tasks = allTasks.toList();
    _tasksStreamcontroller.add(_tasks);
  }

  Future<DatabaseTask> updateTask({
    required DatabaseTask task,
    required String taskName,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //make sure task exist
    await fetchTask(id: task.id);

    //update db
    final updateCount = await db.update(
      taskTable,
      {
        taskNameColumn: taskName,
        isSyncedWithCloudColumn: 0,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
    if (updateCount == 0) {
      throw CouldNotUpdateTask();
    } else {
      final updatedTask = await fetchTask(id: task.id);
      _tasks.removeWhere((task) => task.id == updatedTask.id);
      _tasks.add(updatedTask);
      _tasksStreamcontroller.add(_tasks);
      return updatedTask;
    }
  }

  Future<Iterable<DatabaseTask>> fetchAllTask() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final tasks = await db.query(taskTable);

    return tasks.map((taskRows) => DatabaseTask.fromRow(taskRows));
  }

  Future<DatabaseTask> fetchTask({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final tasks = await db.query(
      taskTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (tasks.isEmpty) {
      throw CouldNotFindTask();
    } else {
      final task = DatabaseTask.fromRow(tasks.first);
      _tasks.removeWhere((task) => task.id == id);
      _tasks.add(task);
      _tasksStreamcontroller.add(_tasks);
      return task;
    }
  }

  Future<int> deleteAllTasks() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(taskTable);
    _tasks = [];
    _tasksStreamcontroller.add(_tasks);
    return numberOfDeletions;
  }

  Future<void> deleteTask({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      taskTable,
      where: 'id=?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteTask();
    } else {
      _tasks.removeWhere((task) => task.id == id);
      _tasksStreamcontroller.add(_tasks);
    }
  }

  Future<DatabaseTask> createTask({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    //Make sure owner exist in the database with the correct id.
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    const text = '';
    //Create tasks in database
    final taskId = await db.insert(taskTable, {
      userIdColumn: owner.id,
      taskNameColumn: text,
      isSyncedWithCloudColumn: 1
    });

    final task = DatabaseTask(
      id: taskId,
      userId: owner.id,
      taskName: text,
      isSyncedWithCloud: true,
    );

    _tasks.add(task);
    _tasksStreamcontroller.add(_tasks);

    return task;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExist();
    }
    final userId =
        await db.insert(userTable, {emailColumn: email.toLowerCase()});
    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // emptyyyy
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createTaskTable);
      await _catcheTasks();
//CREATE THE TASK TABLE
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumntsDirectory;
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID= $id, email =$email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseTask {
  final int id;
  final int userId;
  final String taskName;
  final bool isSyncedWithCloud;

  const DatabaseTask({
    required this.id,
    required this.userId,
    required this.taskName,
    required this.isSyncedWithCloud,
  });

  DatabaseTask.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        taskName = map[taskNameColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  bool operator ==(covariant DatabaseTask other) => id == other.id;

  @override
  String toString() => 'ID=$id, Task is $taskName';

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;
}

const dbName = 'tasks.db';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const taskTable = 'tasks';
const userIdColumn = 'user_id';
const taskNameColumn = 'task';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createTaskTable = '''CREATE TABLE IF NOT EXISTS "tasks" (
      "id" INTEGER NOT NULL,
      "user_id" INTEGER NOT NULL,
      "task" TEXT,
      "is_synced_with_cloud" INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY("user_id") REFERENCES "user"("id"), 
      PRIMARY KEY("id" AUTOINCREMENT)
      );''';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
      "id" INTEGER NOT NULL,
      "email" TEXT NOT NULL UNIQUE,
      PRIMARY KEY("id" AUTOINCREMENT)
      );''';
