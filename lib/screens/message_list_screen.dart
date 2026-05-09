import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_refresh_app/controllers/message_controller.dart';
import 'package:flutter_refresh_app/models/message.dart';
import 'package:flutter_refresh_app/screens/message_detail_screen.dart';
import 'package:flutter_refresh_app/screens/message_form_screen.dart';
import 'package:provider/provider.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageController>(
      builder:
          (BuildContext context, MessageController controller, Widget? child) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  controller.hasSelection
                      ? '${controller.selectedIds.length} selected'
                      : 'Messages',
                ),
                actions: <Widget>[
                  if (controller.hasSelection)
                    IconButton(
                      key: const Key('deleteSelectedButton'),
                      onPressed: () =>
                          _confirmDeleteSelected(context, controller),
                      icon: const Icon(Icons.delete),
                    ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                key: const Key('createMessageButton'),
                onPressed: () => _openCreate(context),
                child: const Icon(Icons.add),
              ),
              body: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      key: const Key('searchField'),
                      controller: _searchController,
                      onChanged: controller.searchMessages,
                      decoration: InputDecoration(
                        hintText: 'Search messages',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: controller.query.isEmpty
                            ? null
                            : IconButton(
                                key: const Key('clearSearchButton'),
                                onPressed: () {
                                  _searchController.clear();
                                  controller.searchMessages('');
                                },
                                icon: const Icon(Icons.clear),
                              ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildList(controller),
                  ),
                ],
              ),
            );
          },
    );
  }

  Widget _buildList(MessageController controller) {
    if (controller.messages.isEmpty) {
      return const Center(child: Text('No messages yet. Tap + to create one.'));
    }

    return ListView.separated(
      itemCount: controller.messages.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final Message message = controller.messages[index];
        final bool isSelected =
            message.id != null && controller.selectedIds.contains(message.id);
        return ListTile(
          key: Key('messageTile_${message.id ?? index}'),
          leading: controller.hasSelection
              ? Checkbox(
                  value: isSelected,
                  onChanged: (_) {
                    if (message.id != null) {
                      controller.toggleSelection(message.id!);
                    }
                  },
                )
              : null,
          title: Text(
            message.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // subtitle: Text(message.imagePath == null ? 'Text only' : 'Image attached'),
          trailing: message.imagePath == null
              ? null
              : ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(
                    File(message.imagePath!),
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 52,
                      height: 52,
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
          selected: isSelected,
          onLongPress: () {
            if (message.id != null) {
              controller.toggleSelection(message.id!);
            }
          },
          onTap: () {
            if (controller.hasSelection) {
              if (message.id != null) {
                controller.toggleSelection(message.id!);
              }
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MessageDetailScreen(messageId: message.id!),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const MessageFormScreen()));
  }

  Future<void> _confirmDeleteSelected(
    BuildContext context,
    MessageController controller,
  ) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete selected messages?'),
        content: Text('Delete ${controller.selectedIds.length} message(s).'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('confirmDeleteSelectedButton'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await controller.deleteSelectedMessages();
    }
  }
}
