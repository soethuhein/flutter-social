import 'package:flutter_refresh_app/controllers/message_controller.dart';
import 'package:flutter_refresh_app/models/message.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late InMemoryMessageStore store;
  late MessageController controller;

  setUp(() {
    store = InMemoryMessageStore();
    controller = MessageController(store: store);
  });

  test('create and list messages', () async {
    await controller.saveMessage(content: 'My post');

    expect(controller.messages.length, 1);
    expect(controller.messages.first.content, 'My post');
  });

  test('edit message and keep image path', () async {
    await controller.saveMessage(content: 'Old', imagePath: '/img/a.png');
    final Message first = controller.messages.first;

    await controller.saveMessage(
      id: first.id,
      content: 'New',
      imagePath: '/img/b.png',
    );

    expect(controller.messages.first.content, 'New');
    expect(controller.messages.first.imagePath, '/img/b.png');
  });

  test('search and first match is accessible from list', () async {
    await controller.saveMessage(content: 'blog alpha');
    await controller.saveMessage(content: 'wiki beta');

    await controller.searchMessages('blog');

    expect(controller.messages.length, 1);
    expect(controller.messages.first.content, 'blog alpha');
  });

  test('delete single and delete selected group', () async {
    await controller.saveMessage(content: 'one');
    await controller.saveMessage(content: 'two');
    await controller.saveMessage(content: 'three');

    final int singleId = controller.messages.first.id!;
    await controller.deleteMessage(singleId);

    final List<int> ids = controller.messages.map((Message m) => m.id!).toList();
    controller.toggleSelection(ids[0]);
    controller.toggleSelection(ids[1]);
    await controller.deleteSelectedMessages();

    expect(controller.messages, isEmpty);
  });
}
