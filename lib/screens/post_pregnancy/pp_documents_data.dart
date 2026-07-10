// =============================================================================
//  Baby documents - model + in-memory store
// -----------------------------------------------------------------------------
//  A calm home for the important papers of a child's early years: the birth
//  certificate, Aadhaar, passport, insurance, medical papers and anything else.
//  Each document is a title + category + date + optional image/PDF attachments.
//  A ChangeNotifier singleton like the app's other stores; a real backend slots
//  in behind these same methods later. Nothing here depends on the pregnancy app.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_attachments.dart';

/// The small, fixed set of buckets a document can belong to.
const List<String> kBabyDocCategories = [
  'Birth certificate',
  'Aadhaar',
  'Passport',
  'Insurance',
  'Medical',
  'Other',
];

class BabyDocument {
  const BabyDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    this.attachments = const [],
    this.notes = '',
  });
  final String id;
  final String title;
  final String category; // one of kBabyDocCategories
  final String date; // display, e.g. "18 Mar 2026"
  final List<Attachment> attachments;
  final String notes;
}

// A couple of seeded examples so the screen never opens empty.
const List<BabyDocument> kBabyDocuments = [
  BabyDocument(
    id: 'doc_birth',
    title: 'Birth certificate',
    category: 'Birth certificate',
    date: '18 Mar 2026',
    notes: 'Municipal corporation copy. Original kept safe at home.',
  ),
  BabyDocument(
    id: 'doc_insurance',
    title: 'Health insurance (child add-on)',
    category: 'Insurance',
    date: '2 Apr 2026',
    notes: 'Added to the family floater policy.',
  ),
];

class BabyDocumentsStore extends ChangeNotifier {
  BabyDocumentsStore._();
  static final BabyDocumentsStore instance = BabyDocumentsStore._();

  final List<BabyDocument> _docs = [...kBabyDocuments];

  List<BabyDocument> get documents => List.unmodifiable(_docs);

  void addDocument(BabyDocument d) {
    _docs.insert(0, d);
    notifyListeners();
  }

  void updateDocument(int i, BabyDocument d) {
    if (i >= 0 && i < _docs.length) {
      _docs[i] = d;
      notifyListeners();
    }
  }

  void removeDocument(int i) {
    if (i >= 0 && i < _docs.length) {
      _docs.removeAt(i);
      notifyListeners();
    }
  }
}
