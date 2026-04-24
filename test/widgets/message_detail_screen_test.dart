import 'package:flutter/material.dart';
import 'package:flutter_refresh_app/controllers/message_controller.dart';
import 'package:flutter_refresh_app/screens/message_detail_screen.dart';
import 'package:flutter_refresh_app/services/image_service.dart';
import 'package:flutter_refresh_app/services/message_share_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../helpers/fakes.dart';

void main() {
  testWidgets('detail view shows single message and shares it',
      (WidgetTester tester) async {
    final InMemoryMessageStore store = InMemoryMessageStore();
    final MessageController controller = MessageController(store: store);
    final FakeImageService imageService = FakeImageService();
    final FakeShareService shareService = FakeShareService();

    await controller.saveMessage(content: 'share this post');
    final int id = controller.messages.first.id!;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ImageService>.value(value: imageService),
          Provider<MessageShareService>.value(value: shareService),
          ChangeNotifierProvider<MessageController>.value(value: controller),
        ],
        child: MaterialApp(home: MessageDetailScreen(messageId: id)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('messageContentText')), findsOneWidget);
    expect(find.text('share this post'), findsOneWidget);

    await tester.tap(find.byKey(const Key('shareMessageButton')));
    await tester.pumpAndSettle();

    expect(shareService.sharedMessage, isNotNull);
    expect(shareService.sharedMessage!.content, 'share this post');
  });
}
