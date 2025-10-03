import 'package:dart_application_2/Score.dart';

class StudentScore extends Score {
  StudentScore(this.name, super.score);

  String name;

  @override
  void showInfo() {
    print("이름: $name, 점수: $score");
  }
}
