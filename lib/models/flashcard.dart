class Flashcard {
  final String question;
  final String op1;
  final String op2;
  final String op3;
  final String correct;

  Flashcard({
    required this.question,
    required this.op1,
    required this.op2,
    required this.op3,
    required this.correct,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      question: json['question'],
      op1: json['op1'],
      op2: json['op2'],
      op3: json['op3'],
      correct: json['correct'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'op1': op1,
      'op2': op2,
      'op3': op3,
      'correct': correct,
    };
  }
}
