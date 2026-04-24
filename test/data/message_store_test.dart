import 'package:flutter_refresh_app/data/database_helper.dart';
import 'package:flutter_refresh_app/data/message_store.dart';
import 'package:flutter_refresh_app/models/message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper helper;
  late MessageStore store;

  setUp(() {
    sqfliteFfiInit();
    helper = DatabaseHelper(
      databaseFactory: databaseFactoryFfi,
      dbPathResolver: () async => inMemoryDatabasePath,
    );
    store = SqfliteMessageStore(helper);
  });

  tearDown(() async {
    await helper.close();
  });

  test('create, fetch single and fetch list', () async {
    final DateTime now = DateTime.now();
    final int id = await store.createMessage(
      Message(
        content: 'First post',
        imagePath: null,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final Message? single = await store.fetchMessageById(id);
    final List<Message> list = await store.fetchMessages();

    expect(single, isNotNull);
    expect(single!.content, 'First post');
    expect(list.length, 1);
  });

  test('update message', () async {
    final DateTime now = DateTime.now();
    final int id = await store.createMessage(
      Message(
        content: 'Original',
        imagePath: null,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final Message original = (await store.fetchMessageById(id))!;
    await store.updateMessage(
      original.copyWith(content: 'Updated message', imagePath: '/tmp/pic.png'),
    );

    final Message updated = (await store.fetchMessageById(id))!;
    expect(updated.content, 'Updated message');
    expect(updated.imagePath, '/tmp/pic.png');
  });

  test('search messages returns matching list', () async {
    final DateTime now = DateTime.now();
    await store.createMessage(
      Message(
        content: 'Hello blog world',
        imagePath: null,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await store.createMessage(
      Message(
        content: 'Other note',
        imagePath: null,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final List<Message> matches = await store.searchMessages('blog');
    expect(matches.length, 1);
    expect(matches.first.content, contains('blog'));
  });

  test('delete single and delete selected group', () async {
    final DateTime now = DateTime.now();
    final int a = await store.createMessage(
      Message(content: 'A', imagePath: null, createdAt: now, updatedAt: now),
    );
    final int b = await store.createMessage(
      Message(content: 'B', imagePath: null, createdAt: now, updatedAt: now),
    );
    final int c = await store.createMessage(
      Message(content: 'C', imagePath: null, createdAt: now, updatedAt: now),
    );

    await store.deleteMessage(a);
    await store.deleteMessages(<int>[b, c]);

    final List<Message> remaining = await store.fetchMessages();
    expect(remaining, isEmpty);
  });
}
