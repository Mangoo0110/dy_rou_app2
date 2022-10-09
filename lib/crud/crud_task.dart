import 'dart:ffi';
import 'dart:html';


import 'package:dy_rou/crud/crud_exception.dart';
import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';


class TaskService {
  Database? _db;
  Future<Task> updateTask({
    required Task task,
    required String taskName
  }) async{
    final db = _getDatabaseOrThrough();

    await fetchTask(id: task.id);
   final updateCount = await db.update(taskTable, {
      taskNameColumn: taskName,
      isSyncedWithCloudColumn: 0,
    });
    if(updateCount==0)
    {
      throw CouldNotUpdateTask();
    }
    else{
      return await fetchTask(id: task.id);
    }
  }

  Future<Iterable<Task> > fetchAllTask() async {
   final db = _getDatabaseOrThrough();
    final tasks = await db.query(
      taskTable
    );

   return tasks.map((taskRows) => Task.fromRow(taskRows));

  }

  Future<Task> fetchTask({required int id}) async {
    final db = _getDatabaseOrThrough();
    final task = await db.query(
      taskTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if(task.isEmpty){
      throw CouldNotFoundTask();
    }
    else{
      return Task.fromRow(task.first);
    }
  }

  Future<int> deleteAllTasks() async {
    final db = _getDatabaseOrThrough();
    return await db.delete(taskTable);
  }

  Future<void> deleteTask({required int id}) async {
    final db = _getDatabaseOrThrough();
    final deletedCount = await db.delete(
      taskTable,
      where: 'id=?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteTask();
    }
  }

  Future<Task> createTask({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrough();

    //Make sure owner exist in the database with the correct id.
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFoundUser();
    }
    const text = '';
    //Create tasks in database
    final taskId = await db.insert(taskTable, {
      userIdColumn: owner.id,
      taskNameColumn: text,
      isSyncedWithCloudColumn: 1
    });

    final task = Task(
      id: taskId,
      userId: owner.id,
      taskName: text,
      isSyncedWithCloud: true,
    );

    return task;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrough();

    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFoundUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrough();
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
    final db = _getDatabaseOrThrough();
    final deletedCount = await db.delete(
      userTable,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrough() {
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
class Task {
  final int id;
  final int userId;
  final String taskName;
  final bool isSyncedWithCloud;

  Task({
    required this.id,
    required this.userId,
    required this.taskName,
    required this.isSyncedWithCloud,
  });

  Task.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        taskName = map[taskNameColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  bool operator ==(covariant Task other) => id == other.id;

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
const taskTable = 'task';
const userIdColumn = 'user_id';
const taskNameColumn = 'task';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createTaskTable = ''' CREATE TABLE IF NOT EXIST "tasks"(
      "id" INTGER NOT NULL,
      "user_id" INTGER NOT NULL,
      "task" TEXT NOT NULL UNIQUE,
      "is_synced_with_cloud" INTGER NOT NULL DEFAULT 0,
      FOREIGN KEY("user_id") REFERENCES "user"("id"), 
      PRIMARY KEY("id" AUTOINCREMENT)
      );

''';
const createUserTable = ''' CREATE TABLE IF NOT EXIST "user"(
      "id" INTGER NOT NULL,
      "email" TEXT NOT NULL UNIQUE,
      PRIMARY KEY("id" AUTOINCREMENT)
      );

''';
