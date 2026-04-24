import 'package:flutter/material.dart';
import 'package:flutter_refresh_app/controllers/message_controller.dart';
import 'package:flutter_refresh_app/screens/message_form_screen.dart';
import 'package:flutter_refresh_app/services/image_service.dart';
import 'package:flutter_refresh_app/services/message_share_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../helpers/fakes.dart';

void main() {
  testWidgets('form validates content and can save a new message',
      (WidgetTester tester) async {
    final InMemoryMessageStore store = InMemoryMessageStore();
    final MessageController controller = MessageController(store: store);
    final FakeImageService imageService = FakeImageService();
    final FakeShareService shareService = FakeShareService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ImageService>.value(value: imageService),
          Provider<MessageShareService>.value(value: shareService),
          ChangeNotifierProvider<MessageController>.value(value: controller),
        ],
        child: const MaterialApp(home: MessageFormScreen()),
      ),
    );

    await tester.tap(find.byKey(const Key('saveMessageButton')));
    await tester.pumpAndSettle();
    expect(find.text('Content is required'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('contentField')), 'new social post');
    await tester.tap(find.byKey(const Key('saveMessageButton')));
    await tester.pumpAndSettle();

    expect(controller.messages.length, 1);
    expect(controller.messages.first.content, 'new social post');
  });

  testWidgets('form can request image from gallery and camera',
      (WidgetTester tester) async {
    final InMemoryMessageStore store = InMemoryMessageStore();
    final MessageController controller = MessageController(store: store);
    final FakeImageService imageService =
        FakeImageService(galleryPath: null, cameraPath: null);
    final FakeShareService shareService = FakeShareService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ImageService>.value(value: imageService),
          Provider<MessageShareService>.value(value: shareService),
          ChangeNotifierProvider<MessageController>.value(value: controller),
        ],
        child: const MaterialApp(home: MessageFormScreen()),
      ),
    );

    await tester.tap(find.byKey(const Key('pickGalleryButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pickCameraButton')));
    await tester.pumpAndSettle();

    expect(imageService.galleryCalls, 1);
    expect(imageService.cameraCalls, 1);
  });
}
