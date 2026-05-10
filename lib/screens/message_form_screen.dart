import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_refresh_app/controllers/message_controller.dart';
import 'package:flutter_refresh_app/models/message.dart';
import 'package:flutter_refresh_app/services/image_service.dart';
import 'package:provider/provider.dart';

class MessageFormScreen extends StatefulWidget {
  const MessageFormScreen({super.key, this.message});

  final Message? message;

  @override
  State<MessageFormScreen> createState() => _MessageFormScreenState();
}

class _MessageFormScreenState extends State<MessageFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;
  String? _imagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.message?.content ?? '',
    );
    _imagePath = widget.message?.imagePath;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.message != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Message' : 'Create Message'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              key: const Key('contentField'),
              controller: _contentController,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Message content',
                border: OutlineInputBorder(),
              ),
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Content is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: <Widget>[
                OutlinedButton.icon(
                  key: const Key('pickGalleryButton'),
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo),
                  label: const Text('Gallery'),
                ),
                OutlinedButton.icon(
                  key: const Key('pickCameraButton'),
                  onPressed: _pickFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                if (_imagePath != null)
                  TextButton.icon(
                    key: const Key('removeImageButton'),
                    onPressed: () => setState(() => _imagePath = null),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove image'),
                  ),
              ],
            ),
            if (_imagePath != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_imagePath!),
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              key: const Key('saveMessageButton'),
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(_isSaving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImageService imageService = context.read<ImageService>();
      final String? path = await imageService.pickFromGallery();
      if (path != null && mounted) {
        setState(() => _imagePath = path);
      }
    } on PlatformException {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera/Gallery permission required')),
      );
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final ImageService imageService = context.read<ImageService>();
      final String? path = await imageService.pickFromCamera();
      if (path != null && mounted) {
        setState(() => _imagePath = path);
      }
    } on PlatformException {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera/Gallery permission required')),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    final MessageController controller = context.read<MessageController>();
    await controller.saveMessage(
      id: widget.message?.id,
      content: _contentController.text,
      imagePath: _imagePath,
    );

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.message != null ? 'Message updated' : 'Message created',
        ),
      ),
    );
    Navigator.of(context).pop();
  }
}
