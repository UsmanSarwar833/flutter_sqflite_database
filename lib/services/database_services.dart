import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_databse/models/task.dart';

class DatabaseService {
  static Database? _db;

  ///constructor for database service class.
  DatabaseService._constructor();

  /// singleton instance
  static final DatabaseService instance = DatabaseService._constructor();
  final String _tasksTableName = "tasks";
  final String _tasksIdColumnName = "id";
  final String _tasksContentColumnName = "content";
  final String _tasksStatusColumnName = "status";

//integer => for number  and  real => for decimal
  ///database getter
  Future<Database> get dataBase async {
    if (_db != null) return _db!;
    _db = await getDataBase();
    return _db!;
  }

  Future<Database> getDataBase() async {
    ///path for database directory.
    final dataBaseDirPath = await getDatabasesPath();
    final dataBasePath = join(dataBaseDirPath, "master_db.db");

    ///open up database using sqflite
    final dataBase =
        await openDatabase(dataBasePath, version: 1, onCreate: (db, version) {
      db.execute('''
             CREATE TABLE $_tasksTableName (
             $_tasksIdColumnName  INTEGER PRIMARY KEY,
             $_tasksContentColumnName TEXT NOT NULL,
             $_tasksStatusColumnName INTEGER NOT NULL
             )''');
    });
    return dataBase;
  }

  void addTask(String content) async {
    final db = await dataBase;
    await db.insert(_tasksTableName, {
      _tasksContentColumnName: content,
      _tasksStatusColumnName: 0,
    });
  }

  Future<List<Task>> getTasks() async {
    final db = await dataBase;
    final data = await db.query(_tasksTableName);
    List<Task> task = data
        .map((e) => Task(
            status: e["status"] as int,
            id: e["id"] as int,
            content: e["content"] as String))
        .toList();
    return task;
  }

  void updateTaskStatus(int id, int status) async {
    final db = await dataBase;
    await db.update(
      _tasksTableName,
      {
        _tasksStatusColumnName: status,
      },
      where: 'id = ?',

      /// ? replace with whereArgs id.
      whereArgs: [id],
    );
  }

  void deleteTask(int id) async {
    final db = await dataBase;
    db.delete(_tasksTableName, where: 'id = ?', whereArgs: [id]);
  }
}
