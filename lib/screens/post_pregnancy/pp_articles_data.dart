// =============================================================================
//  Articles - content model + data
// -----------------------------------------------------------------------------
//  Backs the browsable Article Archive (S20·archive) and the Article Reader
//  (S20). The archive is an SEO/casual-browse surface - never promoted on the
//  home. The "Why baby sleep cycles change at 4 months" article carries the full
//  designed reader body; the rest are list entries (full copy on the way).
//  Faithful to Claude Design "post pregnancy - content.dc.html". Isolated module.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.category,
    required this.age,
    required this.readMin,
    this.author = 'Dr. Ananya Rao',
    this.authorRole = 'Paediatrician',
    this.featured = false,
  });

  final String id;
  final String title;
  final String category; // Sleep / Feeding / Development / Health
  final String age; // '3–6 mo'
  final int readMin;
  final String author;
  final String authorRole;
  final bool featured;

  Color get categoryColor => articleCategoryColor(category);
}

const List<String> kArticleTopics = ['All', 'Sleep', 'Feeding', 'Development', 'Health'];
const List<String> kArticleAges = ['0–3 mo', '3–6 mo', '6–12 mo', '1–2 yr'];

Color articleCategoryColor(String category) {
  switch (category) {
    case 'Development':
    case 'Health':
      return ppPurple;
    default: // Sleep, Feeding
      return ppCoral;
  }
}

const List<Article> kArticles = [
  Article(id: 'sleepcycles', title: 'Why baby sleep cycles change at 4 months', category: 'Sleep', age: '3–6 mo', readMin: 6, featured: true),
  Article(id: 'leap4', title: 'The 4-month shift, decoded: what the fussiness means', category: 'Development', age: '3–6 mo', readMin: 5),
  Article(id: 'distractedfeeds', title: 'Distracted feeds: is he getting enough?', category: 'Feeding', age: '3–6 mo', readMin: 3),
  Article(id: 'drowsy', title: 'Drowsy but awake: the hardest skill', category: 'Sleep', age: '3–6 mo', readMin: 5),
  Article(id: 'vaccines', title: 'The 4-month vaccines, explained calmly', category: 'Health', age: '3–6 mo', readMin: 4),
  Article(id: 'regression', title: 'The 4-month regression, night by night', category: 'Sleep', age: '3–6 mo', readMin: 4),
];

List<Article> filterArticles({String topic = 'All', String age = '3–6 mo'}) => kArticles
    .where((a) => topic == 'All' || a.category == topic)
    .where((a) => a.age == age)
    .toList();
