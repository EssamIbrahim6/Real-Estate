import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:real_estate_app/firebase_options.dart';

import 'data/estate_translations.dart';

/// Migration script for Firestore estate localization.
///
/// Features:
/// - Safe dry-run by default (--dry-run)
/// - Explicit apply flag (--apply)
/// - Local JSON backup before changes (--backup)
/// - Strict idempotency: ignores documents that already have `title_ar` or `title_en`
/// - Backward compatibility: preserves root `title`, `description`, `location.address`, `location.city`
///
/// Usage:
///   dart run tool/migrate_estates_localization.dart [--dry-run | --apply] [--backup]
Future<void> main(List<String> args) async {
  final isApply = args.contains('--apply');
  final isBackup = args.contains('--backup');
  final isDryRun = !isApply || args.contains('--dry-run');

  stdout.writeln('====================================================');
  stdout.writeln('  ESTATE LOCALIZATION MIGRATION TOOL');
  stdout.writeln('====================================================');
  stdout.writeln('Mode: ${isDryRun ? "DRY-RUN (No changes will be written)" : "APPLY (Writing changes to Firestore)"}');
  stdout.writeln('Backup: ${isBackup ? "ENABLED (Backing up to local JSON)" : "DISABLED"}');
  stdout.writeln('----------------------------------------------------');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    stdout.writeln('Note: Firebase already initialized or running in local context: $e');
  }

  final firestore = FirebaseFirestore.instance;
  final migrator = EstateLocalizationMigrator(firestore);

  final summary = await migrator.run(
    dryRun: isDryRun,
    createBackup: isBackup,
  );

  stdout.writeln('----------------------------------------------------');
  stdout.writeln('Migration completed.');
  stdout.writeln('Total documents scanned: ${summary.totalScanned}');
  stdout.writeln('Already localized (skipped): ${summary.alreadyLocalized}');
  stdout.writeln('Migrated / would migrate: ${summary.migratedCount}');
  if (summary.backupPath != null) {
    stdout.writeln('Backup saved to: ${summary.backupPath}');
  }
  stdout.writeln('====================================================');
}

class MigrationSummary {
  final int totalScanned;
  final int alreadyLocalized;
  final int migratedCount;
  final String? backupPath;

  const MigrationSummary({
    required this.totalScanned,
    required this.alreadyLocalized,
    required this.migratedCount,
    this.backupPath,
  });
}

class EstateLocalizationMigrator {
  final FirebaseFirestore _firestore;

  const EstateLocalizationMigrator(this._firestore);

  /// Performs the localization migration on estates collection.
  Future<MigrationSummary> run({
    required bool dryRun,
    required bool createBackup,
  }) async {
    final collection = _firestore.collection('estates');
    final snapshot = await collection.get();

    int totalScanned = snapshot.docs.length;
    int alreadyLocalized = 0;
    int migratedCount = 0;

    final List<Map<String, dynamic>> backupRecords = [];
    final WriteBatch batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      // Check idempotency: If document already has title_ar and title_en, skip
      final hasTitleAr = data.containsKey('title_ar') &&
          data['title_ar'] != null &&
          (data['title_ar'] as String).trim().isNotEmpty;
      final hasTitleEn = data.containsKey('title_en') &&
          data['title_en'] != null &&
          (data['title_en'] as String).trim().isNotEmpty;

      if (hasTitleAr && hasTitleEn) {
        alreadyLocalized++;
        continue;
      }

      final rawTitle = data['title'] as String? ?? '';
      final rawDesc = data['description'] as String? ?? '';
      final rawLocation = data['location'] as Map<String, dynamic>? ?? {};
      final rawAddress = rawLocation['address'] as String? ?? '';
      final rawCity = rawLocation['city'] as String? ?? '';

      final titleEn = data['title_en'] as String? ?? rawTitle;
      final titleAr = data['title_ar'] as String? ??
          EstateTranslations.translateTitle(rawTitle);

      final descEn = data['description_en'] as String? ?? rawDesc;
      final descAr = data['description_ar'] as String? ??
          EstateTranslations.translateDescription(rawDesc, title: rawTitle);

      final addressEn = rawLocation['address_en'] as String? ?? rawAddress;
      final addressAr = rawLocation['address_ar'] as String? ??
          EstateTranslations.translateAddress(rawAddress);

      final cityEn = rawLocation['city_en'] as String? ?? rawCity;
      final cityAr = rawLocation['city_ar'] as String? ??
          EstateTranslations.translateCity(rawCity);

      final updatedLocation = Map<String, dynamic>.from(rawLocation);
      updatedLocation['address_en'] = addressEn;
      updatedLocation['address_ar'] = addressAr;
      updatedLocation['city_en'] = cityEn;
      updatedLocation['city_ar'] = cityAr;

      final updatePayload = <String, dynamic>{
        'title_en': titleEn,
        'title_ar': titleAr,
        'description_en': descEn,
        'description_ar': descAr,
        'location': updatedLocation,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (createBackup) {
        backupRecords.add({
          'id': doc.id,
          'originalData': data,
          'migratedPayload': updatePayload,
        });
      }

      if (!dryRun) {
        batch.update(doc.reference, updatePayload);
      }

      migratedCount++;
    }

    String? backupPath;
    if (createBackup && backupRecords.isNotEmpty) {
      final now = DateTime.now().toIso8601String().replaceAll(':', '-');
      backupPath = 'tool/backups/estates_backup_$now.json';
      final file = File(backupPath);
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(backupRecords));
    }

    if (!dryRun && migratedCount > 0) {
      await batch.commit();
    }

    return MigrationSummary(
      totalScanned: totalScanned,
      alreadyLocalized: alreadyLocalized,
      migratedCount: migratedCount,
      backupPath: backupPath,
    );
  }
}

