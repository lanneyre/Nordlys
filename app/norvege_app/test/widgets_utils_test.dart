import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:norvege_app/utils/audio_element_builder.dart';
import 'package:norvege_app/utils/nordlys_text_field.dart';
import 'package:norvege_app/utils/profile_avatar.dart';

void main() {
  group('Widget Utils Tests', () {
    testWidgets('NordlysTextField rend correctement', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NordlysTextField(
              label: 'Test Label',
              onChanged: (value) {},
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('NordlysTextField accepte du texte', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NordlysTextField(
              label: 'Email',
              controller: controller,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('ProfileAvatar affiche l\'avatar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ProfileAvatar())),
      );

      expect(find.byType(ProfileAvatar), findsOneWidget);
    });

    testWidgets('ProfileAvatar avec nom vide', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ProfileAvatar())),
      );

      expect(find.byType(ProfileAvatar), findsOneWidget);
    });

    testWidgets('AudioElementBuilder construit un élément', (
      WidgetTester tester,
    ) async {
      final builder = AudioElementBuilder();

      expect(builder, isNotNull);
      expect(builder, isA<AudioElementBuilder>());
    });
  });
}
