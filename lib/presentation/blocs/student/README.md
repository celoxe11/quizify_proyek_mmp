# Student Blocs Documentation

## Overview

Dokumentasi ini menjelaskan Bloc yang digunakan oleh student untuk fitur quiz dalam aplikasi Quizify.

## Bloc yang Tersedia

### 1. JoinQuizBloc

Bloc untuk join/memulai quiz menggunakan kode quiz.

**Events:**

- `JoinQuizByCodeEvent(String code)` - Join quiz dan memulai session baru
- `GetQuizInfoByCodeEvent(String code)` - Mendapatkan informasi quiz tanpa memulai session
- `ResetJoinQuizEvent()` - Reset state ke initial

**States:**

- `JoinQuizInitial` - State awal
- `JoinQuizLoading` - Sedang loading
- `JoinQuizSuccess` - Berhasil join quiz (berisi sessionId, quizId, message)
- `QuizInfoLoaded` - Informasi quiz berhasil dimuat (berisi QuizModel)
- `JoinQuizError` - Terjadi error (berisi error message)

**Contoh Penggunaan:**

```dart
// Setup Bloc
BlocProvider(
  create: (context) => JoinQuizBloc(
    StudentRepository(ApiClient()),
  ),
  child: YourWidget(),
)

// Trigger Event
context.read<JoinQuizBloc>().add(
  JoinQuizByCodeEvent('ABC123'),
);

// Listen State
BlocListener<JoinQuizBloc, JoinQuizState>(
  listener: (context, state) {
    if (state is JoinQuizSuccess) {
      // Navigate to quiz page with sessionId and quizId
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => QuizPage(
          sessionId: state.sessionId,
          quizId: state.quizId,
        ),
      ));
    } else if (state is JoinQuizError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: YourWidget(),
)
```

---

### 2. QuizSessionBloc

Bloc untuk mengerjakan quiz, termasuk navigasi soal dan submit jawaban.

**Events:**

- `LoadQuizSessionEvent(String sessionId, String quizId)` - Load quiz session dan soal-soal
- `SelectAnswerEvent(String questionId, String answer)` - Memilih jawaban (tanpa submit)
- `SubmitAnswerEvent(String questionId, String answer)` - Submit jawaban ke server
- `NextQuestionEvent()` - Pindah ke soal berikutnya
- `PreviousQuestionEvent()` - Pindah ke soal sebelumnya
- `GoToQuestionEvent(int index)` - Pindah ke soal tertentu
- `EndQuizSessionEvent()` - Mengakhiri quiz session
- `ResetQuizSessionEvent()` - Reset state ke initial

**States:**

- `QuizSessionInitial` - State awal
- `QuizSessionLoading` - Sedang loading quiz session
- `QuizSessionLoaded` - Quiz session berhasil dimuat
  - Properti: session, questions, currentQuestionIndex, selectedAnswers, submittedQuestions
  - Getters: currentQuestion, currentSelectedAnswer, isCurrentQuestionSubmitted, totalQuestions, answeredCount, isLastQuestion, isFirstQuestion, allQuestionsAnswered
- `QuizSessionSubmitting` - Sedang submit jawaban
- `QuizSessionEnding` - Sedang mengakhiri quiz
- `QuizSessionEnded` - Quiz session selesai (berisi sessionId, score, message)
- `QuizSessionError` - Terjadi error

**Contoh Penggunaan:**

```dart
// Setup Bloc
BlocProvider(
  create: (context) => QuizSessionBloc(
    StudentRepository(ApiClient()),
  )..add(LoadQuizSessionEvent(
    sessionId: widget.sessionId,
    quizId: widget.quizId,
  )),
  child: YourWidget(),
)

// Select Answer (local only)
context.read<QuizSessionBloc>().add(
  SelectAnswerEvent(
    questionId: question.id,
    answer: selectedOption,
  ),
);

// Submit Answer (to server)
context.read<QuizSessionBloc>().add(
  SubmitAnswerEvent(
    questionId: question.id,
    answer: selectedOption,
  ),
);

// Navigate Questions
context.read<QuizSessionBloc>().add(const NextQuestionEvent());
context.read<QuizSessionBloc>().add(const PreviousQuestionEvent());
context.read<QuizSessionBloc>().add(GoToQuestionEvent(5));

// End Quiz
context.read<QuizSessionBloc>().add(const EndQuizSessionEvent());

// Build UI
BlocBuilder<QuizSessionBloc, QuizSessionState>(
  builder: (context, state) {
    if (state is QuizSessionLoaded) {
      final question = state.currentQuestion;
      final selectedAnswer = state.currentSelectedAnswer;
      final isSubmitted = state.isCurrentQuestionSubmitted;

      return Column(
        children: [
          Text('Soal ${state.currentQuestionIndex + 1}/${state.totalQuestions}'),
          Text(question.questionText),
          Text('Terjawab: ${state.answeredCount}/${state.totalQuestions}'),
          // ... build options
        ],
      );
    }
    return CircularProgressIndicator();
  },
)
```

---

### 3. QuizResultBloc

Bloc untuk melihat hasil quiz dan riwayat quiz.

**Events:**

- `LoadQuizResultEvent(String sessionId)` - Load hasil quiz untuk session tertentu
- `LoadQuizHistoryEvent()` - Load riwayat semua quiz yang pernah dikerjakan
- `ResetQuizResultEvent()` - Reset state ke initial

**States:**

- `QuizResultInitial` - State awal
- `QuizResultLoading` - Sedang loading
- `QuizResultLoaded` - Hasil quiz berhasil dimuat
  - Properti: score, totalQuestions, correctAnswers, incorrectAnswers, submissionAnswers, sessionId
  - Getters: percentage, isPassed
- `QuizHistoryLoaded` - Riwayat quiz berhasil dimuat (berisi List<QuizSessionModel>)
- `QuizResultError` - Terjadi error

**Contoh Penggunaan:**

```dart
// Setup Bloc
BlocProvider(
  create: (context) => QuizResultBloc(
    StudentRepository(ApiClient()),
  )..add(LoadQuizResultEvent(widget.sessionId)),
  child: YourWidget(),
)

// Load History
context.read<QuizResultBloc>().add(const LoadQuizHistoryEvent());

// Build UI
BlocBuilder<QuizResultBloc, QuizResultState>(
  builder: (context, state) {
    if (state is QuizResultLoaded) {
      return Column(
        children: [
          Text('Skor: ${state.score}/${state.totalQuestions}'),
          Text('Persentase: ${state.percentage.toStringAsFixed(1)}%'),
          Text('Status: ${state.isPassed ? "LULUS" : "TIDAK LULUS"}'),
          Text('Benar: ${state.correctAnswers}'),
          Text('Salah: ${state.incorrectAnswers}'),
          // ... tampilkan detail jawaban dari submissionAnswers
        ],
      );
    }
    return CircularProgressIndicator();
  },
)
```

---

### 4. PracticeQuestionBloc

Bloc untuk generate dan mengerjakan latihan soal (practice mode).

**Events:**

- `GeneratePracticeQuestionsEvent({String? category, String? difficulty, int count})` - Generate soal latihan
- `SelectPracticeAnswerEvent(String questionId, String answer)` - Pilih jawaban
- `CheckPracticeAnswerEvent(String questionId)` - Cek apakah jawaban benar/salah
- `NextPracticeQuestionEvent()` - Soal berikutnya
- `PreviousPracticeQuestionEvent()` - Soal sebelumnya
- `GoToPracticeQuestionEvent(int index)` - Pindah ke soal tertentu
- `ResetPracticeEvent()` - Reset state

**States:**

- `PracticeQuestionInitial` - State awal
- `PracticeQuestionLoading` - Sedang generate soal
- `PracticeQuestionLoaded` - Soal latihan berhasil dimuat
  - Properti: questions, currentQuestionIndex, selectedAnswers, checkedAnswers
  - Getters: currentQuestion, currentSelectedAnswer, isCurrentAnswerCorrect, isCurrentAnswerChecked, totalQuestions, answeredCount, correctCount, incorrectCount, isLastQuestion, isFirstQuestion, allQuestionsAnswered, scorePercentage
- `PracticeQuestionError` - Terjadi error

**Contoh Penggunaan:**

```dart
// Setup Bloc
BlocProvider(
  create: (context) => PracticeQuestionBloc(
    StudentRepository(ApiClient()),
  ),
  child: YourWidget(),
)

// Generate Practice Questions
context.read<PracticeQuestionBloc>().add(
  GeneratePracticeQuestionsEvent(
    category: 'Matematika',
    difficulty: 'medium',
    count: 10,
  ),
);

// Select Answer
context.read<PracticeQuestionBloc>().add(
  SelectPracticeAnswerEvent(
    questionId: question.id,
    answer: selectedOption,
  ),
);

// Check Answer
context.read<PracticeQuestionBloc>().add(
  CheckPracticeAnswerEvent(question.id),
);

// Navigate
context.read<PracticeQuestionBloc>().add(const NextPracticeQuestionEvent());

// Build UI
BlocBuilder<PracticeQuestionBloc, PracticeQuestionState>(
  builder: (context, state) {
    if (state is PracticeQuestionLoaded) {
      final question = state.currentQuestion;
      final selectedAnswer = state.currentSelectedAnswer;
      final isChecked = state.isCurrentAnswerChecked;
      final isCorrect = state.isCurrentAnswerCorrect;

      return Column(
        children: [
          Text('Soal ${state.currentQuestionIndex + 1}/${state.totalQuestions}'),
          Text(question.questionText),
          if (isChecked) ...[
            Text(isCorrect! ? 'BENAR ✓' : 'SALAH ✗'),
            Text('Jawaban yang benar: ${question.correctAnswer}'),
          ],
          Text('Skor: ${state.scorePercentage.toStringAsFixed(1)}%'),
          Text('Benar: ${state.correctCount}, Salah: ${state.incorrectCount}'),
          // ... build options
        ],
      );
    }
    return CircularProgressIndicator();
  },
)
```

---

## Student Repository

Semua Bloc di atas menggunakan `StudentRepository` yang berisi method untuk berkomunikasi dengan backend API.

**Setup Repository:**

```dart
final repository = StudentRepository(ApiClient());
```

**API Endpoints yang Digunakan:**

- `POST /student/startquizbycode/:code` - Start quiz session
- `GET /student/quiz/code/:code` - Get quiz info
- `GET /student/session/:sessionId` - Get session detail
- `GET /student/quiz/:quizId/questions` - Get quiz questions
- `POST /student/session/:sessionId/answer` - Submit answer
- `POST /student/session/:sessionId/end` - End quiz session
- `GET /student/session/:sessionId/result` - Get quiz result
- `GET /student/session/:sessionId/answers` - Get submission answers
- `GET /student/my-quiz-history` - Get quiz history
- `GET /student/practice/generate` - Generate practice questions

---

## Import

Untuk menggunakan semua student blocs, cukup import:

```dart
import 'package:quizify_proyek_mmp/presentation/blocs/student/student_blocs.dart';
import 'package:quizify_proyek_mmp/data/repositories/student_repository.dart';
```

---

## Workflow Lengkap Student

### 1. Join Quiz

```
JoinQuizPage -> JoinQuizBloc -> JoinQuizByCodeEvent
-> JoinQuizSuccess (sessionId, quizId) -> Navigate to QuizPage
```

### 2. Mengerjakan Quiz

```
QuizPage -> QuizSessionBloc -> LoadQuizSessionEvent
-> QuizSessionLoaded -> Display questions
-> User select answer -> SelectAnswerEvent -> Update UI
-> User submit answer -> SubmitAnswerEvent -> Mark as submitted
-> User navigate questions -> NextQuestionEvent / PreviousQuestionEvent
-> User finish quiz -> EndQuizSessionEvent -> QuizSessionEnded
-> Navigate to ResultPage
```

### 3. Melihat Hasil

```
ResultPage -> QuizResultBloc -> LoadQuizResultEvent
-> QuizResultLoaded -> Display score, percentage, answers detail
```

### 4. Latihan Soal

```
PracticePage -> PracticeQuestionBloc -> GeneratePracticeQuestionsEvent
-> PracticeQuestionLoaded -> Display question
-> User select answer -> SelectPracticeAnswerEvent
-> User check answer -> CheckPracticeAnswerEvent
-> Show correct/incorrect immediately with explanation
-> Navigate to next question -> NextPracticeQuestionEvent
-> View final score from scorePercentage
```

---

## Catatan Penting

1. **QuizSession vs Practice**:

   - QuizSession submit ke server dan disimpan hasilnya
   - Practice hanya lokal, untuk latihan saja

2. **State Management**: Semua Bloc menggunakan Equatable untuk state comparison

3. **Error Handling**: Setiap Bloc memiliki error state yang bisa ditampilkan ke user

4. **Reset**: Setiap Bloc bisa direset ke initial state

5. **Dependencies**: Pastikan menambahkan `flutter_bloc` dan `equatable` di pubspec.yaml
