// ════════════════════════════════════════════════════════════════════════════
// TEMPORARY DEBUG FILE — paste this anywhere and call debugFetchGigs()
// from your initState to see exactly what Firestore returns.
// Delete this file after debugging.
// ════════════════════════════════════════════════════════════════════════════

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

Future<void> debugFetchGigs() async {
  final db = FirebaseFirestore.instance;

  debugPrint('════════════════════════════════════');
  debugPrint('🔍 DEBUG: Fetching ALL docs from gigs collection (no filters)');
  debugPrint('════════════════════════════════════');

  try {
    // ── 1. Fetch EVERYTHING — no filters at all ───────────────────────────
    final allSnap = await db.collection('gigs').get();
    debugPrint('📦 Total docs in gigs collection: ${allSnap.docs.length}');

    if (allSnap.docs.isEmpty) {
      debugPrint('❌ Collection is EMPTY or wrong collection name!');
      debugPrint('   Check: is your collection named exactly "gigs" in Firestore?');
      return;
    }

    // ── 2. Print each doc's key fields ────────────────────────────────────
    for (final doc in allSnap.docs) {
      final d = doc.data();
      debugPrint('────────────────────────────────────');
      debugPrint('📄 Doc ID     : ${doc.id}');
      debugPrint('   gigId      : ${d['gigId']}');
      debugPrint('   status     : ${d['status']}');         // MOST IMPORTANT
      debugPrint('   drName     : ${d['drName']}');
      debugPrint('   drId       : ${d['drId']}');
      debugPrint('   title      : ${d['title']}');
      debugPrint('   category   : ${d['category']}');
      debugPrint('   isFeatured : ${d['isFeatured']}');
      debugPrint('   coverImageUrl exists: ${d['coverImageUrl'] != null && (d['coverImageUrl'] as String).isNotEmpty}');
      debugPrint('   basicPackage exists: ${d['basicPackage'] != null}');
      if (d['basicPackage'] != null) {
        final bp = d['basicPackage'] as Map<String, dynamic>;
        debugPrint('   basicPackage.price: ${bp['price']}');
      }
    }

    // ── 3. Now try with status == 'active' ────────────────────────────────
    debugPrint('════════════════════════════════════');
    debugPrint('🔍 Now filtering: status == "active"');
    final activeSnap = await db.collection('gigs')
        .where('status', isEqualTo: 'active')
        .get();
    debugPrint('✅ Active gigs found: ${activeSnap.docs.length}');

    // ── 4. Try status == 'pending' ────────────────────────────────────────
    debugPrint('🔍 Now filtering: status == "pending"');
    final pendingSnap = await db.collection('gigs')
        .where('status', isEqualTo: 'pending')
        .get();
    debugPrint('⏳ Pending gigs found: ${pendingSnap.docs.length}');

    // ── 5. Summary ────────────────────────────────────────────────────────
    debugPrint('════════════════════════════════════');
    debugPrint('📊 SUMMARY:');
    debugPrint('   Total gigs       : ${allSnap.docs.length}');
    debugPrint('   Status = active  : ${activeSnap.docs.length}');
    debugPrint('   Status = pending : ${pendingSnap.docs.length}');

    if (activeSnap.docs.isEmpty && pendingSnap.docs.length > 0) {
      debugPrint('');
      debugPrint('💡 FIX: Your gigs have status="pending" not "active".');
      debugPrint('   Go to Firebase Console → gigs collection');
      debugPrint('   → open each doc → change status field from "pending" to "active"');
      debugPrint('   OR ask admin to approve the gig.');
    }

    if (allSnap.docs.isEmpty) {
      debugPrint('💡 FIX: No gigs exist. Upload a gig from the admin panel first.');
    }

  } catch (e) {
    debugPrint('❌ ERROR: $e');
    debugPrint('');
    if (e.toString().contains('permission-denied')) {
      debugPrint('💡 FIX: Firestore security rules are blocking reads.');
      debugPrint('   Go to Firebase Console → Firestore → Rules');
      debugPrint('   Make sure patients can read the gigs collection.');
    }
    if (e.toString().contains('failed-precondition')) {
      debugPrint('💡 FIX: Missing Firestore index.');
      debugPrint('   Check your debug console for a link — click it to auto-create.');
    }
  }

  debugPrint('════════════════════════════════════');
}