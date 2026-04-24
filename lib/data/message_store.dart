import 'package:flutter_refresh_app/data/database_helper.dart';
import 'package:flutter_refresh_app/models/message.dart';
import 'package:sqflite/sqflite.dart';

abstract class MessageStore {
  Future<List<Message>> fetchMessages();
  Future<Message?> fetchMessageById(int id);
  Future<int> createMessage(Message message);
  Future<void> updateMessage(Message message);
  Future<void> deleteMessage(int id);
  Future<void> deleteMessages(List<int> ids);
  Future<List<Message>> searchMessages(String query);
}

class SqfliteMessageStore implements MessageStore {
  SqfliteMessageStore(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<Database> _db() => _databaseHelper.database();

  @override
  Future<int> createMessage(Message message) async {
    final Database db = await _db();
    return db.insert('messages', message.toMap()..remove('id'));
  }

  @override
  Future<void> deleteMessage(int id) async {
    final Database db = await _db();
    await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: <Object>[id],
    );
  }

  @override
  Future<void> deleteMessages(List<int> ids) async {
    if (ids.isEmpty) {
      return;
    }
    final Database db = await _db();
    final String placeholders = List<String>.filled(ids.length, '?').join(',');
    await db.delete(
      'messages',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  @override
  Future<Message?> fetchMessageById(int id) async {
    final Database db = await _db();
    final List<Map<String, Object?>> maps = await db.query(
      'messages',
      where: 'id = ?',
      whereArgs: <Object>[id],
      limit: 1,
    );
    if (maps.isEmpty) {
      return null;
    }
    return Message.fromMap(maps.first);
  }

  @override
  Future<List<Message>> fetchMessages() async {
    final Database db = await _db();
    final List<Map<String, Object?>> maps = await db.query(
      'messages',
      orderBy: 'updated_at DESC',
    );
    return maps.map(Message.fromMap).toList();
  }

  @override
  Future<List<Message>> searchMessages(String query) async {
    final Database db = await _db();
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return fetchMessages();
    }
    final String wildcard = '%${trimmed.toLowerCase()}%';
    final List<Map<String, Object?>> maps = await db.query(
      'messages',
      where: 'LOWER(content) LIKE ?',
      whereArgs: <Object>[wildcard],
      orderBy: 'updated_at DESC',
    );
    return maps.map(Message.fromMap).toList();
  }

  @override
  Future<void> updateMessage(Message message) async {
    final Database db = await _db();
    await db.update(
      'messages',
      message.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: <Object>[message.id!],
    );
  }
}
