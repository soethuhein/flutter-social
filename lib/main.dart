import 'package:flutter/material.dart';
import 'package:flutter_refresh_app/controllers/message_controller.dart';
import 'package:flutter_refresh_app/data/database_helper.dart';
import 'package:flutter_refresh_app/data/message_store.dart';
import 'package:flutter_refresh_app/screens/message_list_screen.dart';
import 'package:flutter_refresh_app/services/image_service.dart';
import 'package:flutter_refresh_app/services/message_share_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseHelper>(create: (_) => DatabaseHelper()),
        Provider<MessageStore>(
          create: (BuildContext context) =>
              SqfliteMessageStore(context.read<DatabaseHelper>()),
        ),
        Provider<ImageService>(create: (_) => ImagePickerService()),
        Provider<MessageShareService>(
          create: (_) => SharePlusMessageShareService(),
        ),
        ChangeNotifierProvider<MessageController>(
          create: (BuildContext context) =>
              MessageController(store: context.read<MessageStore>())
                ..loadMessages(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Message Hub',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const MessageListScreen(),
      ),
    );
  }
}
