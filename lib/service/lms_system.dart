import '../model/course.dart';
import '../model/course_result.dart';
import '../model/student.dart';

class LmsSystem {
  final List<Student> students = [];
  final List<Course> courses = [];
  final List<CourseResult> results = [];
 
  void addStudent({required String studentId, required String studentName}) {
    // ! Student shall not exist already
    Student? student = _findStudentOrNull(studentId);
    if (student != null) {
      throw Exception('Student $student already exists');
    }

    students.add(Student(id: studentId, name: studentName));
  }
 
 
  void removeStudent({required String studentId}) {
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }
    students.removeWhere((student) => student.id == studentId);
    for (Course course in courses) {
      course.studentIds.remove(studentId);
    }
    results.removeWhere((result) => result.studentId == studentId);
  }

  void addCourse({required String courseId, required String courseName}) {
    Course? course = _findCourseOrNull(courseId);
    if (course != null) {
      throw Exception('Course $courseId already exists');
    }
    courses.add(Course(id: courseId, name: courseName));
  }

  void removeCourse({required String courseId}) {
    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }
    courses.removeWhere((course) => course.id == courseId);
    results.removeWhere((result) => result.courseId == courseId);
  }

  void enrollStudent({required String studentId, required String courseId}) {
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }

    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }

    if (course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId already enrolled in course $courseId');
    }

    course.studentIds.add(studentId);
  }

  void discardStudentFromCourse({
    required String studentId,
    required String courseId,
  }) {
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }

    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }

    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled in course $courseId');
    }

    course.studentIds.remove(studentId);
    results.removeWhere(
      (result) => result.studentId == studentId && result.courseId == courseId,
    );
  }

  CourseResult addResult({
    required String studentId,
    required String courseId,
    required double score,
    String? resultId,
  }) {
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }

    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }

    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled in course $courseId');
    }

    if (score < 0 || score > 100) {
      throw Exception('Score must be between 0 and 100');
    }

    bool hasResult = results.any(
      (r) => r.studentId == studentId && r.courseId == courseId,
    );
    if (hasResult) {
      throw Exception(
        'Result already exists for student $studentId in course $courseId',
      );
    }

    final id = resultId ?? 'R_${results.length + 1}_${studentId}_$courseId';
    if (_findResultOrNull(id) != null) {
      throw Exception('Result $id already exists');
    }

    final result = CourseResult(
      id: id,
      studentId: studentId,
      courseId: courseId,
      score: score,
    );
    results.add(result);
    return result;
  }

  void removeResult({required String resultId}) {
    CourseResult? result = _findResultOrNull(resultId);
    if (result == null) {
      throw Exception('Result $resultId not found');
    }
    results.removeWhere((r) => r.id == resultId);
  }

  CourseResult? _findResultOrNull(String resultId) {
    for (CourseResult r in results) {
      if (r.id == resultId) {
        return r;
      }
    }
    return null;
  }

  Course? _findCourseOrNull(String courseId) {
    for (Course c in courses) {
      if (c.id == courseId) {
        return c;
      }
    }
    return null;
  }

  Student? _findStudentOrNull(String studentId) {
    for (Student s in students) {
      if (s.id == studentId) {
        return s;
      }
    }
    return null; // not found
  } 
}
