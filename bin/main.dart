import 'dart:convert';
import 'dart:io';
import 'package:dart_application_2/dojeon/ScoreProgram.dart';
import 'package:dart_application_2/StudentScore.dart';

void main() {
  String readFilePath1 = 'lib/pilsu/students.txt'; // 읽어올 파일 경로
  String saveFilePath1 = "lib/pilsu/result.txt"; // 저장할 파일 경로

  String readFilePath2 = 'lib/dojeon/students.txt'; // 읽어올 파일 경로
  String saveFilePath2 = "lib/dojeon/result.txt"; // 저장할 파일 경로

  //필수 과제
  print("필수 과제");
  pilSu(readFilePath1, saveFilePath1);

  print("---------------------------------------");
  print("도전 과제");
  //도전과제
  ScoreProgram test = ScoreProgram(
    readFilePath: readFilePath2,
    saveFilePath: saveFilePath2,
  );
  test.runProgram();
}

//학생들 정보 읽어서 StudentScore 리스트로 출력
List<StudentScore> readScoreFile(String path) {
  List<StudentScore> result = [];

  try {
    final myFile = File(path);
    final lines = myFile.readAsLinesSync(); // 디폴트값이 utf8이라 안써도 오류 안남

    for (var line in lines) {
      final temp = line.split(',');
      if (temp.length != 2) {
        throw FormatException('잘못된 데이터 형식: $line');
      } //이름과 성적으로 잘 분리됐는지 확인

      result.add(StudentScore(temp[0], int.parse(temp[1])));
      print(temp);
    }
  } catch (e) {
    print('파일 읽기 실패: $e');
    exit(1);
  }

  return result;
}

// 학생 정보 저장
void saveStudentScore(String path, StudentScore result) {
  try {
    final file = File(path);
    file.writeAsStringSync('이름: ${result.name}, 점수: ${result.score}');
    print("저장이 완료되었습니다.");
  } catch (e) {
    print("저장에 실패했습니다: $e");
  }
}

// 필수과제
void pilSu(String readFilePath, String saveFilePath) {
  List<StudentScore> studentsScore = []; // txt파일에서 가져온 정보 저장 공간

  studentsScore = readScoreFile(readFilePath); // txt파일 읽어오기

  bool loopAgain = true;

  while (loopAgain) {
    stdout.write('어떤 학생의 점수를 확인하시겠습니까?');
    String? userInput = stdin.readLineSync(
      encoding: utf8,
    ); // encoing: utf8 이라고 명시 안하면 오류 생김

    late StudentScore result;

    // StudentScore 리스트에 있는지 확인
    for (var student in studentsScore) {
      if (student.name == userInput) {
        result = student;
        loopAgain = false;
        result.showInfo();
        break;
      }
    }

    if (loopAgain) {
      print("잘못된 학생 이름을 입력하셨습니다. 다시 입력해주세요.");
    } else {
      //result.txt에 저장
      saveStudentScore(saveFilePath, result);
    }
  }
}
