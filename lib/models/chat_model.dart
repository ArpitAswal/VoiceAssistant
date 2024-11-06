class ChatRequestModel {
  final List<Contents> contents;

  ChatRequestModel({required this.contents});

  Map<String, dynamic> toJson() {
    return {
      'contents': contents.map((content) => content.toJson()).toList(),
    };
  }
}

class Contents {
  final String role;
  final List<Parts> parts;

  Contents({required this.role, required this.parts});

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'parts': parts.map((part) => part.toJson()).toList(),
    };
  }
}

class Parts {
  final String text;

  Parts({required this.text});

  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }
}
