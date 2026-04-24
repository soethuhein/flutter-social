import 'package:flutter/foundation.dart';
import 'package:flutter_refresh_app/data/message_store.dart';
import 'package:flutter_refresh_app/models/message.dart';

class MessageController extends ChangeNotifier {
  MessageController({required MessageStore store}) : _store = store;

  final MessageStore _store;

  List<Message> _messages = <Message>[];
  bool _isLoading = false;
  String _query = '';
  final Set<int> _selectedIds = <int>{};

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String get query => _query;
  Set<int> get selectedIds => _selectedIds;
  bool get hasSelection => _selectedIds.isNotEmpty;

  Future<void> loadMessages() async {
    _setLoading(true);
    _messages = await _store.fetchMessages();
    _selectedIds.clear();
    _setLoading(false);
  }

  Future<void> searchMessages(String value) async {
    _query = value;
    _setLoading(true);
    _messages = await _store.searchMessages(value);
    _selectedIds.removeWhere((int id) =>
        !_messages.any((Message message) => message.id == id));
    _setLoading(false);
  }

  Future<void> saveMessage({
    int? id,
    required String content,
    String? imagePath,
  }) async {
    final String trimmed = content.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final DateTime now = DateTime.now();
    if (id == null) {
      await _store.createMessage(
        Message(
          content: trimmed,
          imagePath: imagePath,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else {
      final Message? current = await _store.fetchMessageById(id);
      if (current == null) {
        return;
      }
      await _store.updateMessage(
        current.copyWith(
          content: trimmed,
          imagePath: imagePath,
          updatedAt: now,
        ),
      );
    }

    if (_query.trim().isEmpty) {
      await loadMessages();
    } else {
      await searchMessages(_query);
    }
  }

  Future<void> deleteMessage(int id) async {
    await _store.deleteMessage(id);
    _selectedIds.remove(id);
    if (_query.trim().isEmpty) {
      await loadMessages();
    } else {
      await searchMessages(_query);
    }
  }

  Future<void> deleteSelectedMessages() async {
    final List<int> ids = _selectedIds.toList(growable: false);
    await _store.deleteMessages(ids);
    _selectedIds.clear();
    if (_query.trim().isEmpty) {
      await loadMessages();
    } else {
      await searchMessages(_query);
    }
  }

  void toggleSelection(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
