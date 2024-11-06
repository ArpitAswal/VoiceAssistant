class ChatResponseModel {
  final List<Candidate>? candidates;

  ChatResponseModel({this.candidates});

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      candidates: json['candidates'] != null
          ? (json['candidates'] as List)
          .map((e) => Candidate.fromJson(e))
          .toList()
          : null,
    );
  }
}

class Candidate {
  final Content content;

  Candidate({required this.content});

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      content: Content.fromJson(json['content']),
    );
  }
}

class Content {
  final List<Part> parts;

  Content({required this.parts});

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      parts: (json['parts'] as List).map((e) => Part.fromJson(e)).toList(),
    );
  }
}

class Part {
  final String text;

  Part({required this.text});

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(text: json['text']);
  }
}
