import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';

part 'avatar_upload_provider.g.dart';

// ---------------------------------------------------------------------------
// Current avatar URL — seeded from Firebase Auth (Google photo) on init.
// Updated in-memory after a successful S3 upload.
// ---------------------------------------------------------------------------
@riverpod
class AvatarUrl extends _$AvatarUrl {
  @override
  String? build() => FirebaseAuth.instance.currentUser?.photoURL;

  void set(String url) => state = url;
}

// ---------------------------------------------------------------------------
// Upload state
// ---------------------------------------------------------------------------
enum AvatarUploadStatus { idle, loading, success, error }

class AvatarUploadState {
  const AvatarUploadState({
    this.status = AvatarUploadStatus.idle,
    this.errorMessage,
  });
  final AvatarUploadStatus status;
  final String? errorMessage;
}

@riverpod
class AvatarUpload extends _$AvatarUpload {
  @override
  AvatarUploadState build() => const AvatarUploadState();

  Future<void> upload(File imageFile) async {
    state = const AvatarUploadState(status: AvatarUploadStatus.loading);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not authenticated');

      final backendDio = ref.read(dioProvider);

      // 1. Get presigned PUT URL from backend.
      final urlResp = await backendDio
          .get('/api/v1/users/$uid/avatar/upload-url');
      final uploadUrl = urlResp.data['uploadUrl'] as String;
      final finalUrl = urlResp.data['finalUrl'] as String;

      // 2. PUT image bytes directly to S3 (no auth headers — presigned URL).
      final s3Dio = Dio();
      final bytes = await imageFile.readAsBytes();
      await s3Dio.put(
        uploadUrl,
        data: Stream.fromIterable(bytes.map((b) => [b])),
        options: Options(
          headers: {
            'Content-Type': 'image/jpeg',
            'Content-Length': bytes.length,
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      // 3. Persist photo URL in backend DB.
      await backendDio.put(
        '/api/v1/users/$uid/avatar',
        data: {'photoUrl': finalUrl},
      );

      // 4. Update in-memory avatar URL.
      ref.read(avatarUrlProvider.notifier).set(finalUrl);

      state = const AvatarUploadState(status: AvatarUploadStatus.success);
    } catch (e) {
      state = AvatarUploadState(
        status: AvatarUploadStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', '').trim(),
      );
    }
  }
}
