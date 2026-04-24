import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_refresh_app/controllers/message_controller.dart';
import 'package:flutter_refresh_app/models/message.dart';
import 'package:flutter_refresh_app/screens/message_form_screen.dart';
import 'package:flutter_refresh_app/services/message_share_service.dart';
import 'package:provider/provider.dart';

class MessageDetailScreen extends StatelessWidget {
  const MessageDetailScreen({super.key, required this.messageId});

  final int messageId;

  @override
  Widget build(BuildContext context) {
    final MessageController controller = context.watch<MessageController>();
    final List<Message> matches = controller.messages
        .where((Message item) => item.id == messageId)
        .toList(growable: false);
    final Message? message = matches.isEmpty ? null : matches.first;

    if (message == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Message')),
        body: const Center(child: Text('Message not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Detail'),
        actions: <Widget>[
          IconButton(
            key: const Key('shareMessageButton'),
            onPressed: () async {
              final MessageShareService shareService =
                  context.read<MessageShareService>();
              await shareService.share(message);
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            key: const Key('editMessageButton'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MessageFormScreen(message: message),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            key: const Key('deleteMessageButton'),
            onPressed: () => _confirmDelete(context, controller, messageId),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            message.content,
            key: const Key('messageContentText'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          if (message.imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(message.imagePath!),
                key: const Key('messageImage'),
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    MessageController controller,
    int id,
  ) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this message?'),
        content: const Text('This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('confirmDeleteMessageButton'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await controller.deleteMessage(id);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
