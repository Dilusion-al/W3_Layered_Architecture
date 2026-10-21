import 'package:test/test.dart';
import '../lib/model/course_result.dart';
import '../lib/service/lms_system.dart';

void main() {
  test('creates a student', () {
    final lms = LmsSystem();

  //Create a student
    lms.addStudent(studentId: 'S1', studentName: "ronan");
    expect(lms.students.first.name, 'ronan');

    lms.removeStudent(studentId: 'S1');
    expect(lms.students.length, 0);
  });

  group('Task 1 - Add and remove courses', () {
    test('adds and removes a course', () {
      final lms = LmsSystem();

      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      expect(lms.courses.length, 1);
      expect(lms.courses.first.id, 'C1');
      expect(lms.courses.first.name, 'Mobile Development');

      lms.removeCourse(courseId: 'C1');
      expect(lms.courses.length, 0);
    });

    test('rejects a duplicate course ID', () {
      final lms = LmsSystem();

      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      expect(
        () => lms.addCourse(courseId: 'C1', courseName: 'Duplicate Course'),
        throwsException,
      );
    });

    test('rejects removal of a nonexistent course', () {
      final lms = LmsSystem();

      expect(
        () => lms.removeCourse(courseId: 'C999'),
        throwsException,
      );
    });
  });

  group('Task 2 - Enroll a student in a course', () {
    test('enrolls an existing student in an existing course', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Alice');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');

      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      final course = lms.courses.firstWhere((c) => c.id == 'C1');
      expect(course.studentIds.contains('S1'), isTrue);
    });

    test('rejects enrollment if the student does not exist', () {
      final lms = LmsSystem();
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');

      expect(
        () => lms.enrollStudent(studentId: 'S999', courseId: 'C1'),
        throwsException,
      );
    });

    test('rejects enrollment if the course does not exist', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Alice');

      expect(
        () => lms.enrollStudent(studentId: 'S1', courseId: 'C999'),
        throwsException,
      );
    });

    test('rejects duplicate enrollment', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Alice');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');

      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      expect(
        () => lms.enrollStudent(studentId: 'S1', courseId: 'C1'),
        throwsException,
      );
    });
  });

  group('Task 3 - Remove a student from a course', () {
    test('removes an existing enrollment', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Alice');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1');

      final course = lms.courses.firstWhere((c) => c.id == 'C1');
      expect(course.studentIds.contains('S1'), isFalse);
    });

    test('rejects removal of a nonexistent enrollment', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Alice');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');

      expect(
        () => lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1'),
        throwsException,
      );
    });

    test('verifies that student and course still exist after enrollment is removed', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Alice');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1');

      expect(lms.students.any((s) => s.id == 'S1'), isTrue);
      expect(lms.courses.any((c) => c.id == 'C1'), isTrue);
    });

    test('verifies the chosen policy for associated results when discarding student', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Alice');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.results.add(CourseResult(id: 'R1', studentId: 'S1', courseId: 'C1', score: 90));

      lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1');

      expect(lms.results.where((r) => r.studentId == 'S1' && r.courseId == 'C1'), isEmpty);
    });

    test('removes a student who has enrollments in multiple courses', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Alice');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.addCourse(courseId: 'C2', courseName: 'Web Development');

      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.enrollStudent(studentId: 'S1', courseId: 'C2');
      lms.results.add(CourseResult(id: 'R1', studentId: 'S1', courseId: 'C1', score: 90));
      lms.results.add(CourseResult(id: 'R2', studentId: 'S1', courseId: 'C2', score: 80));

      lms.removeStudent(studentId: 'S1');

      expect(lms.students.any((s) => s.id == 'S1'), isFalse);
      expect(lms.courses.firstWhere((c) => c.id == 'C1').studentIds.contains('S1'), isFalse);
      expect(lms.courses.firstWhere((c) => c.id == 'C2').studentIds.contains('S1'), isFalse);
      expect(lms.results.where((r) => r.studentId == 'S1'), isEmpty);
    });
  });

  group('Task 4 - Add a result to a course', () {
    test('adds a valid result', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Alice');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      final result = lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);

      expect(lms.results.length, 1);
      expect(result.studentId, 'S1');
      expect(result.courseId, 'C1');
      expect(result.score, 85);
    });

    test('rejects a result for a nonexistent student or course', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Alice');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      expect(
        () => lms.addResult(studentId: 'S999', courseId: 'C1', score: 85),
        throwsException,
      );
      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C999', score: 85),
        throwsException,
      );
    });

    test('rejects a result for a student who is not enrolled', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Alice');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');

      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C1', score: 85),
        throwsException,
      );
    });

    test('rejects an invalid score', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Alice');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C1', score: -5),
        throwsException,
      );
      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C1', score: 105),
        throwsException,
      );
    });

    test('rejects duplicate results for the same student and course', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Alice');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');

      lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);
      expect(
        () => lms.addResult(studentId: 'S1', courseId: 'C1', score: 90),
        throwsException,
      );
    });
  });

  group('Task 5 - Remove a student result', () {
    test('removes an existing result', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Alice');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      final result = lms.addResult(studentId: 'S1', courseId: 'C1', score: 85, resultId: 'R1');

      expect(lms.results.length, 1);
      lms.removeResult(resultId: result.id);
      expect(lms.results.isEmpty, isTrue);
    });

    test('rejects removal of a nonexistent result', () {
      final lms = LmsSystem();

      expect(
        () => lms.removeResult(resultId: 'R999'),
        throwsException,
      );
    });

    test('verifies student, course, and unrelated results remain unchanged', () {
      final lms = LmsSystem();
      lms.addStudent(studentId: 'S1', studentName: 'Alice');
      lms.addStudent(studentId: 'S2', studentName: 'Bob');
      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');

      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.enrollStudent(studentId: 'S2', courseId: 'C1');

      final r1 = lms.addResult(studentId: 'S1', courseId: 'C1', score: 85, resultId: 'R1');
      final r2 = lms.addResult(studentId: 'S2', courseId: 'C1', score: 95, resultId: 'R2');

      lms.removeResult(resultId: r1.id);

      expect(lms.results.length, 1);
      expect(lms.results.first.id, r2.id);
      expect(lms.students.length, 2);
      expect(lms.courses.first.studentIds.contains('S1'), isTrue);
      expect(lms.courses.first.studentIds.contains('S2'), isTrue);
    });
  });

  group('Full LMS Scenario', () {
    test('executes complete workflow from requirement specifications', () {
      final lms = LmsSystem();

      lms.addStudent(studentId: 'S1', studentName: 'Alice');
      lms.addStudent(studentId: 'S2', studentName: 'Bob');

      lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');

      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.enrollStudent(studentId: 'S2', courseId: 'C1');

      lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);
      lms.addResult(studentId: 'S2', courseId: 'C1', score: 92);

      lms.removeStudent(studentId: 'S1');

      expect(lms.students.any((s) => s.id == 'S1'), isFalse);
      expect(lms.courses.first.studentIds.contains('S1'), isFalse);
      expect(lms.results.any((r) => r.studentId == 'S1'), isFalse);

      expect(lms.students.any((s) => s.id == 'S2'), isTrue);
      expect(lms.courses.first.studentIds.contains('S2'), isTrue);
      expect(lms.results.any((r) => r.studentId == 'S2'), isTrue);
    });
  });
}


