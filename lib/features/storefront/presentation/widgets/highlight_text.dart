import 'package:flutter/material.dart';

/// [text] with every case-insensitive occurrence of [query] in [match] style
/// (the reference's bold "Pani Puri" inside "Jaishankar Pani Puriwala").
TextSpan highlightMatches(String text, String query, {required TextStyle base, required TextStyle match}) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return TextSpan(text: text, style: base);
  final haystack = text.toLowerCase();
  final spans = <TextSpan>[];
  var start = 0;
  while (true) {
    final index = haystack.indexOf(needle, start);
    if (index < 0) break;
    if (index > start) spans.add(TextSpan(text: text.substring(start, index)));
    spans.add(TextSpan(text: text.substring(index, index + needle.length), style: match));
    start = index + needle.length;
  }
  if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
  return TextSpan(style: base, children: spans);
}
