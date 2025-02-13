import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static Future<Database> db() async {
    return openDatabase(
      join(await getDatabasesPath(), 'kindacode.db'),
      version: 2, // Versi diperbarui untuk migrasi
      onCreate: (Database database, int version) async {
        await database.execute("""
          CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            title TEXT,
            description TEXT,
            genre TEXT,
            voteAverage REAL,
            image TEXT,
            createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
          )
        """);
      },
      onUpgrade: (Database database, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await database.execute("ALTER TABLE items ADD COLUMN image TEXT");
        }
      },
    );
  }

  // *Membaca semua data*
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id");
  }

  // *Membaca satu data berdasarkan id*
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // *Membuat data baru dengan gambar*
  static Future<int> createItem(String title, String? description, String genre,
      double voteAverage, String? image) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'genre': genre,
      'voteAverage': voteAverage,
      'image': image
    };
    return db.insert('items', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // *Memperbarui data termasuk gambar*
  static Future<int> updateItem(int id, String title, String? description,
      String genre, double voteAverage, String? image) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'genre': genre,
      'voteAverage': voteAverage,
      'image': image,
      'createdAt': DateTime.now().toString()
    };
    return db.update('items', data, where: "id = ?", whereArgs: [id]);
  }

  // *Menghapus data*
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    await db.delete('items', where: "id = ?", whereArgs: [id]);
  }
}
