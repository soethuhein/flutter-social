import 'package:flutter_refresh_app/data/message_store.dart';
import 'package:flutter_refresh_app/models/message.dart';
import 'package:flutter_refresh_app/services/image_service.dart';
import 'package:flutter_refresh_app/services/message_share_service.dart';

class InMemoryMessageStore implements MessageStore {
  int _nextId = 1;
  final List<Message> _items = <Message>[];

  @override
  Future<int> createMessage(Message message) async {
    final int id = _nextId++;
    _items.add(message.copyWith(id: id));
    return id;
  }

  @override
  Future<void> deleteMessage(int id) async {
    _items.removeWhere((Message message) => message.id == id);
  }

  @override
  Future<void> deleteMessages(List<int> ids) async {
    _items.removeWhere((Message message) => ids.contains(message.id));
  }

  @override
  Future<Message?> fetchMessageById(int id) async {
    final List<Message> matches =
        _items.where((Message message) => message.id == id).toList();
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<List<Message>> fetchMessages() async {
    final List<Message> copy = List<Message>.from(_items);
    copy.sort((Message a, Message b) => b.updatedAt.compareTo(a.updatedAt));
    return copy;
  }

  @override
  Future<List<Message>> searchMessages(String query) async {
    final String trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return fetchMessages();
    }
    return _items
        .where((Message message) =>
            message.content.toLowerCase().contains(trimmed))
        .toList(growable: false);
  }

  @override
  Future<void> updateMessage(Message message) async {
    final int index = _items.indexWhere((Message item) => item.id == message.id);
    if (index >= 0) {
      _items[index] = message;
    }
  }
}

class FakeImageService implements ImageService {
  FakeImageService({this.galleryPath, this.cameraPath});

  final String? galleryPath;
  final String? cameraPath;
  int galleryCalls = 0;
  int cameraCalls = 0;

  @override
  Future<String?> pickFromCamera() async {
    cameraCalls += 1;
    return cameraPath;
  }

  @override
  Future<String?> pickFromGallery() async {
    galleryCalls += 1;
    return galleryPath;
  }
}

class FakeShareService implements MessageShareService {
  Message? sharedMessage;

  @override
  Future<void> share(Message message) async {
    sharedMessage = message;
  }
}
