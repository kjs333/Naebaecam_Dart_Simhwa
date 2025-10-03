import 'dart:io';
import 'dart:convert';
import 'package:dart_application_2/StudentScore.dart';

class ScoreProgram {
  ScoreProgram({required this.readFilePath, required this.saveFilePath}) {
    readFileMakeMap();
  }
  Map<String, StudentScore> studentMap = {};
  String readFilePath;
  String saveFilePath;

  // students.txt 파일에 있는 학생들 이름과 점수 가져와서 리스트에 저장
  void readFileMakeMap() {
    try {
      final myFile = File(readFilePath);
      final lines = myFile.readAsLinesSync(); // 디폴트값이 utf8이라 안써도 오류 안남

      if (lines.isEmpty) {
        print("빈 파일입니다.");
        exit(1);
      }

      for (var line in lines) {
        final temp = line.split(',');
        if (temp.length != 2) {
          throw FormatException('잘못된 데이터 형식: $line');
        }
        studentMap[temp[0]] = StudentScore(temp[0], int.parse(temp[1]));
      }
    } catch (e) {
      print('파일 읽기 실패: $e');
      exit(1);
    }
  }

  //평균 점수 출력
  void printMeanScore() {
    double totalScore = 0;
    for (var student in studentMap.values) {
      totalScore += student.score;
    }
    totalScore /= studentMap.length;
    print("전체 평균 점수 : $totalScore");
  }

  //우수생 찾기
  void firstStudentFind() {
    StudentScore? first;
    for (var student in studentMap.values) {
      first ??= student;
      if (student.score > first.score) {
        first = student;
      }
    }
    print("우수생 : ${first?.name} (평균 점수: ${first?.score})");
    saveData(first!);
  }

  void saveData(StudentScore result) {
    stdout.write("저장하시겠습니까? [y/n] : ");
    String? answer = stdin.readLineSync(encoding: utf8);

    if (answer == 'y' || answer == 'Y') {
      try {
        final file = File(saveFilePath);
        file.writeAsStringSync('이름: ${result.name}, 점수: ${result.score}');
        print("저장이 완료되었습니다.");
        return;
      } catch (e) {
        print("저장에 실패했습니다: $e");
      }
    } else {
      print("메뉴로 돌아갑니다.");
      return;
    }
  }

  // 모든 학생 출력
  void printTotal() {
    for (var student in studentMap.values) {
      student.showInfo();
    }
  }

  // 개별 학생 점수 찾기
  void findStudentScore() {
    while (true) {
      stdout.write("어떤 학생의 통계를 확인하시겠습니까? (뒤로가기는 'q' 입력) ");
      String? userInput = stdin.readLineSync(encoding: utf8);

      if (userInput == 'q') {
        print("메뉴로 돌아갑니다.");
        return; // 함수 종료
      } else if (userInput == null) {
        print("이름을 입력해주세요."); // 아무것도 입력 안하면
      } else {
        //사용자가 입력한 이름이 맵에 있는지 확인하고 있으면 점수 출력
        StudentScore? result = studentMap[userInput];
        if (result == null) {
          print("잘못된 학생 이름을 입력하셨습니다. 다시 입력해주세요.");
        } else {
          result.showInfo();
          saveData(result);
          return;
        }
      }
    }
  }

  //맵과 파일에 있는 점수를 수정
  void editMapAndFile(String name, int oldScore, int newScore) {
    try {
      //파일에 추가
      var myFile = File(readFilePath);
      var oldContent = myFile.readAsStringSync(); // 디폴트값이 utf8이라 안써도 오류 안남

      // 정보 수정
      String newContent = oldContent.replaceAll(
        '$name,$oldScore',
        '$name,$newScore',
      );
      myFile.writeAsStringSync(newContent);

      //맵에 추가
      studentMap[name] = StudentScore(name, newScore);

      print("$name의 점수를 수정했습니다.");
    } catch (e) {
      print('파일 수정 실패: $e');
      exit(1);
    }
  }

  // 학생 정보 추가, 파일에 저장
  void addStudentScore() {
    while (true) {
      stdout.write("추가할 학생의 이름을 입력해주세요.: (뒤로가기는 'q' 입력) ");
      String? newname = stdin.readLineSync(encoding: utf8); // 이름 입력 받기

      if (newname == 'q') {
        print("메뉴로 돌아갑니다.");
        return;
      } else if (newname == null) {
        print("이름을 입력하세요.");
      } else {
        stdout.write('점수를 입력해주세요.: ');
        String? newScoreString = stdin.readLineSync(encoding: utf8);
        late int? newScoreInt;

        //점수에 아무것도 입력하지 않았을때
        if (newScoreString == null) {
          print("점수를 잘못 입력하셨습니다.");
          continue;
        }

        // 점수에 숫자를 썼는지 확인
        newScoreInt = int.tryParse(newScoreString);

        if (newScoreInt == null) {
          print("점수를 잘못 입력하셨습니다.");
        } else if (studentMap.containsKey(newname)) {
          // 이미 있는 이름이면 점수를 수정할지 묻기
          stdout.write("이미 존재하는 이름입니다. 수정하시겠습니까? [y/n]");
          String? answer = stdin.readLineSync(encoding: utf8);
          if (answer == 'y' || answer == 'Y') {
            int oldScore = studentMap[newname]!.score;
            editMapAndFile(newname, oldScore, newScoreInt);
            return;
          } else {
            print("메뉴로 돌아갑니다.");
            return;
          }
        } else {
          // 새로운 학생이면 추가
          studentMap[newname] = StudentScore(newname, newScoreInt);
          String temp = '\n$newname,$newScoreString'; // 파일에 저장하기 위해 csv형식으로 바꿈
          try {
            var myFile = File(readFilePath);
            myFile.writeAsStringSync(
              temp,
              mode: FileMode.append,
            ); // 기존 정보에 새로운 정보 추가
            print("파일에 추가되었습니다.");
            return;
          } catch (e) {
            print('파일에 정보 추가 실패: $e');
            exit(1);
          }
        }
      }
    }
  }

  void updateScore() {
    while (true) {
      stdout.write("수정할 학생의 이름을 입력해주세요.: (뒤로가기는 'q' 입력) ");
      String? name = stdin.readLineSync(encoding: utf8); // 이름 입력 받기
      late int oldScore;

      if (name == 'q') {
        print("메뉴로 돌아갑니다.");
        return;
      } else if (name == null) {
        print("이름을 입력하세요.");
      } else {
        if (studentMap.containsKey(name)) {
          oldScore = studentMap[name]!.score;
        } else {
          print("잘못된 학생 이름을 입력하셨습니다. 다시 입력해주세요.");
          continue;
        }

        stdout.write('점수를 입력해주세요.: ');
        String? newScoreString = stdin.readLineSync(encoding: utf8);
        late int? newScoreInt;

        //점수에 아무것도 입력하지 않았을때
        if (newScoreString == null) {
          print("점수를 잘못 입력하셨습니다.");
          continue;
        }

        // 점수에 숫자를 썼는지 확인
        newScoreInt = int.tryParse(newScoreString);
        if (newScoreInt == null) {
          // 숫자가 아니면
          print("점수를 잘못 입력하셨습니다.");
        } else {
          editMapAndFile(name, oldScore, newScoreInt);
          return;
        }
      }
    }
  }

  void deleteStudentScore() {
    while (true) {
      stdout.write("삭제할 학생의 이름을 입력해주세요.: (뒤로가기는 'q' 입력) ");
      String? name = stdin.readLineSync(encoding: utf8); // 이름 입력 받기

      if (name == 'q') {
        print("메뉴로 돌아갑니다.");
        return;
      } else if (name == null) {
        print("이름을 입력하세요.");
      } else {
        // 맵에 해당 이름이 있는지 확인
        if (studentMap.containsKey(name)) {
          try {
            var myFile = File(readFilePath);

            String newContent = "";
            // 학생 정보 삭제
            studentMap.remove(name);
            // 원하는 정보를 삭제하고나서 나머지 정보들을 csv형식으로 만들어서 String에 담기
            for (var student in studentMap.values) {
              newContent += "${student.name},${student.score}\n";
            }
            newContent = newContent.substring(
              0,
              newContent.length - 1,
            ); //마지막의 \n 없애기

            // 기존 파일에 덮어쓰기
            myFile.writeAsStringSync(newContent);
            print("삭제하였습니다.");
            return;
          } catch (e) {
            print('정보 삭제 실패: $e');
            exit(1);
          }
        } else {
          print("잘못된 학생 이름을 입력하셨습니다. 다시 입력해주세요.");
        }
      }
    }
  }

  // 프로그램 시작
  void runProgram() {
    String menu =
        '\n 메뉴를 선택하세요 : \n 1. 우수생 출력 \n 2. 전체 평균 점수 출력 \n 3. 모든 학생 조회 \n 4. 학생 점수 조회 \n 5. 학생 점수 수정 \n 6. 학생 추가 \n 7. 학생 삭제 \n 8. 종료';

    while (true) {
      print(menu);
      stdout.write("입력 : ");
      String? userInput = stdin.readLineSync(encoding: utf8);
      switch (userInput) {
        case '1':
          // 우수생 출력 함수
          firstStudentFind();
        case '2':
          // 전체 평균 점수 출력
          printMeanScore();
        case '3':
          // 모든 학생 조회
          printTotal();
        case '4':
          // 개별 학생 점수 조회
          findStudentScore();
        case '5':
          // 학생 점수 수정
          updateScore();
        case '6':
          // 학생 정보 추가
          addStudentScore();
        case '7':
          // 학생 정보 삭제
          deleteStudentScore();
        case '8':
          print("프로그램을 종료합니다.");
          return;
      }
    }
  }
}
