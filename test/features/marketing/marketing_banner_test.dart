import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradesman_manager/core/database/database_helper.dart';
import 'package:tradesman_manager/features/marketing/data/marketing_repository.dart';
import 'package:tradesman_manager/features/marketing/domain/marketing_profile.dart';
import 'package:tradesman_manager/features/marketing/presentation/marketing_studio_screen.dart';
import 'package:tradesman_manager/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:tradesman_manager/l10n/generated/app_localizations.dart';

const _services = [
  'Service 01',
  'Service 02',
  'Service 03',
  'Service 04',
  'Service 05',
  'Service 06',
  'Service 07',
  'Service 08',
  'Service 09',
  'Service 10',
];

const _richProfile = MarketingProfile(
  displayName: 'Northstar Trade Co.',
  headline: 'Reliable property care for homes and businesses',
  offer: 'Free site survey this month',
  services: _services,
  phone: '+880 1783 109748',
  email: 'hello@northstar.example',
  website: 'northstar.example',
  address: '12 Market Road, Dhaka',
  template: MarketingTemplate.professional,
);

void main() {
  test('A4 export scale produces an exact 2480 by 3508 raster', () {
    const previewSize = Size(420, 594);

    final ratio = marketingA4ExportPixelRatio(previewSize);

    expect((previewSize.width * ratio).ceil(), 2480);
    expect((previewSize.height * ratio).ceil(), 3508);
  });

  testWidgets('keeps the logo and business photo as separate flyer assets', (
    tester,
  ) async {
    final profile = MarketingProfile(
      displayName: _richProfile.displayName,
      headline: _richProfile.headline,
      offer: _richProfile.offer,
      services: _richProfile.services,
      phone: _richProfile.phone,
      email: _richProfile.email,
      website: _richProfile.website,
      address: _richProfile.address,
      template: _richProfile.template,
      logoBytes: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      ),
      coverPhotoBytes: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      ),
    );

    await _pumpStudio(tester, profile: profile);

    final banner = find.byKey(
      const ValueKey<String>('marketing-banner-professional'),
    );
    expect(
      find.descendant(
        of: banner,
        matching: find.byKey(const ValueKey<String>('banner-logo')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: banner,
        matching: find.byKey(const ValueKey<String>('banner-cover-photo')),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('editor offers a separate optional business photo control', (
    tester,
  ) async {
    await _pumpStudio(tester, profile: _richProfile);

    final control = find.text('Add business photo');
    expect(control, findsOneWidget);
    expect(find.text('Add company logo'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Professional exposes its premium stage, contact region, and eight services',
    (tester) async {
      await _pumpStudio(tester, profile: _richProfile);

      final banner = find.byKey(
        const ValueKey<String>('marketing-banner-professional'),
      );
      expect(banner, findsOneWidget);
      expect(
        find.descendant(
          of: banner,
          matching: find.byKey(
            const ValueKey<String>('professional-hero-stage'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: banner,
          matching: find.byKey(const ValueKey<String>('banner-contact')),
        ),
        findsOneWidget,
      );

      for (final service in _services.take(8)) {
        expect(
          find.descendant(of: banner, matching: find.text(service)),
          findsOneWidget,
        );
      }
      expect(
        find.descendant(of: banner, matching: find.text('Service 09')),
        findsNothing,
      );
      expect(
        find.descendant(of: banner, matching: find.text('Service 10')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Bold switches to its diagonal stage without losing profile copy',
    (tester) async {
      await _pumpStudio(tester, profile: _richProfile);

      await _selectTemplate(tester, 'Bold');

      final banner = find.byKey(
        const ValueKey<String>('marketing-banner-bold'),
      );
      expect(banner, findsOneWidget);
      expect(
        find.descendant(
          of: banner,
          matching: find.byKey(const ValueKey<String>('bold-diagonal-stage')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: banner,
          matching: find.text(_richProfile.displayName),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: banner, matching: find.text(_richProfile.offer)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: banner, matching: find.text(_richProfile.phone)),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Elegant switches to its editorial stage', (tester) async {
    await _pumpStudio(tester, profile: _richProfile);

    await _selectTemplate(tester, 'Elegant');

    final banner = find.byKey(
      const ValueKey<String>('marketing-banner-elegant'),
    );
    expect(banner, findsOneWidget);
    expect(
      find.descendant(
        of: banner,
        matching: find.byKey(const ValueKey<String>('elegant-editorial-stage')),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Elegant keeps every contact line inside its footer', (
    tester,
  ) async {
    final profile = MarketingProfile(
      displayName: _richProfile.displayName,
      headline: _richProfile.headline,
      offer: _richProfile.offer,
      services: _richProfile.services,
      phone: _richProfile.phone,
      email: _richProfile.email,
      website: _richProfile.website,
      address: _richProfile.address,
      template: MarketingTemplate.elegant,
    );

    await _pumpStudio(tester, profile: profile);

    final banner = find.byKey(
      const ValueKey<String>('marketing-banner-elegant'),
    );
    final footer = find.descendant(
      of: banner,
      matching: find.byKey(const ValueKey<String>('banner-contact')),
    );
    final footerRect = tester.getRect(footer);

    for (final value in [
      profile.phone,
      profile.email,
      profile.website,
      profile.address,
    ]) {
      final contact = find.descendant(of: banner, matching: find.text(value));
      expect(contact, findsOneWidget);
      final contactRect = tester.getRect(contact);
      expect(contactRect.left, greaterThanOrEqualTo(footerRect.left));
      expect(contactRect.right, lessThanOrEqualTo(footerRect.right));
      expect(contactRect.top, greaterThanOrEqualTo(footerRect.top));
      expect(contactRect.bottom, lessThanOrEqualTo(footerRect.bottom));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bold service count reflects the supplied services', (
    tester,
  ) async {
    const profile = MarketingProfile(
      displayName: 'Three Point Repairs',
      headline: 'Fast local help',
      offer: 'Free quote',
      services: ['Electrical', 'Plumbing', 'Painting'],
      phone: '+880 1783 109748',
      email: '',
      website: '',
      address: '',
      template: MarketingTemplate.bold,
    );

    await _pumpStudio(tester, profile: profile);

    final banner = find.byKey(const ValueKey<String>('marketing-banner-bold'));
    final counter = find.descendant(
      of: banner,
      matching: find.byKey(const ValueKey<String>('bold-service-count')),
    );
    expect(counter, findsOneWidget);
    expect(tester.widget<Text>(counter).data, '03');
    expect(tester.takeException(), isNull);
  });

  for (final scenario in [
    (
      languageCode: 'bn',
      direction: TextDirection.ltr,
      profile: const MarketingProfile(
        displayName: 'বিশ্বস্ত কারিগরি সেবা ও নির্মাণ প্রতিষ্ঠান',
        headline:
            'বাড়ি ও ব্যবসাপ্রতিষ্ঠানের জন্য দীর্ঘমেয়াদি নির্ভরযোগ্য রক্ষণাবেক্ষণ সেবা',
        offer: 'এই মাসে সম্পূর্ণ বিনামূল্যে কাজ পরিদর্শন ও মূল্যায়ন',
        services: [
          'বৈদ্যুতিক মেরামত ও নিরাপত্তা পরীক্ষা',
          'পানির লাইন ও পাইপ মেরামত',
          'রান্নাঘর ও বাথরুম সংস্কার',
          'জরুরি কারিগরি সহায়তা',
          'দোকান ও অফিস রক্ষণাবেক্ষণ',
          'রঙ ও অভ্যন্তরীণ সাজসজ্জা',
          'দরজা জানালা মেরামত',
          'নিয়মিত ভবন পরিদর্শন',
        ],
        phone: '+৮৮০ ১৭৮৩ ১০৯৭৪৮',
        email: 'যোগাযোগ@উদাহরণ.বাংলা',
        website: 'বিশ্বস্ত-সেবা.বাংলা',
        address: '১২ দীর্ঘ বাজার সড়ক, ঢাকা, বাংলাদেশ',
        template: MarketingTemplate.professional,
      ),
    ),
    (
      languageCode: 'ur',
      direction: TextDirection.rtl,
      profile: const MarketingProfile(
        displayName: 'قابل اعتماد کاروباری اور فنی خدمات',
        headline:
            'گھروں اور کاروباری اداروں کے لیے مکمل اور قابل اعتماد دیکھ بھال',
        offer: 'اس ماہ مفت معائنہ اور تفصیلی مشورہ حاصل کریں',
        services: [
          'بجلی کی مرمت اور حفاظتی جانچ',
          'پانی کی پائپ لائن کی مرمت',
          'باورچی خانے اور غسل خانے کی تزئین',
          'ہنگامی فنی معاونت',
          'دفتر اور دکان کی دیکھ بھال',
          'رنگ و روغن اور اندرونی سجاوٹ',
          'دروازے اور کھڑکیوں کی مرمت',
          'عمارت کا باقاعدہ معائنہ',
        ],
        phone: '+۸۸۰ ۱۷۸۳ ۱۰۹۷۴۸',
        email: 'رابطہ@example.com',
        website: 'example.com',
        address: '۱۲ طویل مارکیٹ روڈ، ڈھاکہ، بنگلہ دیش',
        template: MarketingTemplate.elegant,
      ),
    ),
  ]) {
    for (final template in MarketingTemplate.values) {
      testWidgets(
        '${scenario.languageCode} ${template.name} long copy renders at large text scale',
        (tester) async {
          final profile = _withTemplate(scenario.profile, template);
          final stageKey = switch (template) {
            MarketingTemplate.professional => 'professional-hero-stage',
            MarketingTemplate.bold => 'bold-diagonal-stage',
            MarketingTemplate.elegant => 'elegant-editorial-stage',
          };

          await _pumpStudio(
            tester,
            profile: profile,
            locale: Locale(scenario.languageCode),
            textScale: 2,
          );

          final banner = find.byKey(
            ValueKey<String>('marketing-banner-${template.name}'),
          );
          expect(banner, findsOneWidget);
          expect(
            find.descendant(
              of: banner,
              matching: find.byKey(ValueKey<String>(stageKey)),
            ),
            findsOneWidget,
          );
          expect(Directionality.of(tester.element(banner)), scenario.direction);
          expect(
            find.descendant(
              of: banner,
              matching: find.text(profile.displayName),
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

MarketingProfile _withTemplate(
  MarketingProfile profile,
  MarketingTemplate template,
) => MarketingProfile(
  displayName: profile.displayName,
  headline: profile.headline,
  offer: profile.offer,
  services: profile.services,
  phone: profile.phone,
  email: profile.email,
  website: profile.website,
  address: profile.address,
  template: template,
  logoBytes: profile.logoBytes,
  coverPhotoBytes: profile.coverPhotoBytes,
);

Future<void> _pumpStudio(
  WidgetTester tester, {
  required MarketingProfile profile,
  Locale locale = const Locale('en'),
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentProfileProvider.overrideWithValue(null),
        marketingRepositoryProvider.overrideWithValue(
          _MemoryMarketingRepository(profile),
        ),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const MarketingStudioScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectTemplate(WidgetTester tester, String label) async {
  final choice = find.text(label);
  await tester.scrollUntilVisible(
    choice,
    500,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(choice);
  await tester.pumpAndSettle();
}

class _MemoryMarketingRepository extends MarketingRepository {
  _MemoryMarketingRepository(this.profile) : super(DatabaseHelper.instance);

  final MarketingProfile profile;

  @override
  Future<MarketingProfile> load() async => profile;
}
