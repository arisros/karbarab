import 'package:flutter/material.dart';
import 'package:karbarab/features/quiz/model/quiz.dart';

class AnswerQuestionCardBattle extends StatefulWidget {
  final String scoreId;
  final int targetScore;
  final QuizModel quiz;
  AnswerQuestionCardBattle({
    Key key,
    this.quiz,
    this.targetScore,
    this.scoreId,
  }) : super(key: key);

  @override
  _AnswerQuestionCardBattleState createState() =>
      _AnswerQuestionCardBattleState();
}

class _AnswerQuestionCardBattleState extends State<AnswerQuestionCardBattle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Answer'),
    );
  }
}
