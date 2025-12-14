import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeacherQuizApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.1.100:8000/api', // Replace with your IP/Domain
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  TeacherQuizApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1. Get the current Firebase ID Token
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken();
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle the http.cat or error responses here
          if (e.response?.headers.value('content-type')?.contains('image') ==
              true) {
            print("Received an error image from http.cat");
          }
          return handler.next(e);
        },
      ),
    );
  }

  // /// POST /quiz - Create a new quiz
  // Future<Response> createQuiz(Map<String, dynamic> data) async {
  //   return await _dio.post('/quiz', data: data);
  // }

  // /// POST /question - Create question with optional image
  // /// Note: Uses 'gambar_soal' as the key based on your parseForm('gambar_soal')
  // Future<Response> createQuestion({
  //   required int quizId,
  //   required String text,
  //   File? imageFile,
  // }) async {
  //   FormData formData = FormData.fromMap({
  //     "quiz_id": quizId,
  //     "text": text, // adjust based on your Question model
  //     if (imageFile != null)
  //       "gambar_soal": await MultipartFile.fromFile(
  //         imageFile.path,
  //         filename: imageFile.path.split('/').last,
  //       ),
  //   });

  //   return await _dio.post('/question', data: formData);
  // }

  // /// GET /myquiz - Fetch teacher's quizzes
  // Future<List<dynamic>> getMyQuizzes() async {
  //   final response = await _dio.get('/myquiz');
  //   return response.data; // Adjust based on your actual JSON structure
  // }

  // /// POST /subscribe - Upgrade to premium
  // Future<Response> subscribe() async {
  //   return await _dio.post('/subscribe');
  // }
}
