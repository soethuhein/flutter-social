import 'package:flutter/material.dart';
import 'package:flutter_refresh_app/controllers/message_controller.dart';
import 'package:flutter_refresh_app/screens/message_list_screen.dart';
import 'package:flutter_refresh_app/services/image_service.dart';
import 'package:flutter_refresh_app/services/message_share_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../helpers/fakes.dart';

void main() {
  testWidgets('list shows messages, searches, and bulk deletes selected',
      (WidgetTester tester) async {
    final InMemoryMessageStore store = InMemoryMessageStore();
    final MessageController controller = MessageController(store: store);
    final FakeImageService imageService = FakeImageService();
    final FakeShareService shareService = FakeShareService();

    await controller.saveMessage(content: 'blog one');
    await controller.saveMessage(content: 'wiki two');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ImageService>.value(value: imageService),
          Provider<MessageShareService>.value(value: shareService),
          ChangeNotifierProvider<MessageController>.value(value: controller),
        ],
        child: const MaterialApp(home: MessageListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('blog one'), findsOneWidget);
    expect(find.text('wiki two'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('searchField')), 'blog');
    await tester.pumpAndSettle();

    expect(find.text('blog one'), findsOneWidget);
    expect(find.text('wiki two'), findsNothing);

    await tester.enterText(find.byKey(const Key('searchField')), '');
    await tester.pumpAndSettle();

    await tester.longPress(find.text('blog one'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteSelectedButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmDeleteSelectedButton')));
    await tester.pumpAndSettle();

    expect(find.text('blog one'), findsNothing);
    expect(find.text('wiki two'), findsOneWidget);
  });
}
