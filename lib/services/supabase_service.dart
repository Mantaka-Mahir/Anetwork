import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Service class to handle Supabase Storage operations
class SupabaseService {
  // Direct reference to Supabase client
  final _supabase = Supabase.instance.client;
  
  // Event images bucket
  static const String eventImagesBucket = 'event_images';
  
  // Admin uploads bucket
  static const String adminUploadsBucket = 'admin_uploads'; 

  // Generate a unique filename
  String _generateUniqueFilename(String originalPath) {
    final extension = path.extension(originalPath).replaceAll('.', '');
    final uuid = const Uuid().v4();
    return '$uuid.$extension';
  }

  // Upload a file to Supabase
  Future<String?> uploadFile(File file, {String? folder, String bucket = eventImagesBucket}) async {
    try {
      // Generate filename based on UUID for uniqueness
      final fileName = _generateUniqueFilename(file.path);
      final filePath = folder != null ? '$folder/$fileName' : fileName;
      
      if (kDebugMode) {
        print(' Uploading file to Supabase');
        print(' Bucket: $bucket');
        print(' Path: $filePath');
        print(' Source file: ${file.path}');
      }
      
      if (kIsWeb) {
        // Web implementation
        final fileBytes = await file.readAsBytes();
        final storageResponse = await _supabase.storage.from(bucket).uploadBinary(filePath, fileBytes);
        if (kDebugMode) {
          print(' Upload successful: $storageResponse');
        }
      } else {
        // Mobile implementation
        final storageResponse = await _supabase.storage.from(bucket).upload(filePath, file);
        if (kDebugMode) {
          print(' Upload successful: $storageResponse');
        }
      }
      
      // Get public URL
      final publicUrl = _supabase.storage.from(bucket).getPublicUrl(filePath);
      
      if (kDebugMode) {
        print(' Public URL: $publicUrl');
      }
      
      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        print(' Error uploading file: $e');
        print(' Stack trace: ${StackTrace.current}');
      }
      return null;
    }
  }

  // Delete a file from Supabase
  Future<bool> deleteFile(String path, {String bucket = eventImagesBucket}) async {
    try {
      // If it's a URL, extract the path
      final filePath = path.contains('http') ? _extractPathFromUrl(path) : path;
      
      if (kDebugMode) {
        print(' Deleting file from Supabase');
        print(' Bucket: $bucket');
        print(' Path: $filePath');
      }
      
      await _supabase.storage.from(bucket).remove([filePath]);
      
      if (kDebugMode) {
        print(' File deleted successfully');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(' Error deleting file: $e');
        print(' Stack trace: ${StackTrace.current}');
      }
      return false;
    }
  }

  // Helper to extract path from URL
  String _extractPathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Find the bucket in the path (after 'public')
      final bucketIndex = pathSegments.indexOf('public') + 1;
      if (bucketIndex > 0 && bucketIndex < pathSegments.length) {
        // Extract everything after the bucket
        return pathSegments.sublist(bucketIndex + 1).join('/');
      }
      
      // Fallback - just use the filename
      return url.split('/').last;
    } catch (e) {
      if (kDebugMode) {
        print(' Error extracting path from URL: $e');
      }
      return url.split('/').last;
    }
  }
}
