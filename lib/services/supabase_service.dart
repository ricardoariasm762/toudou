import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class SupabaseService {

  final supabase = Supabase.instance.client;

  Future<List> getTasks() async {
    final response = await supabase.from('tasks').select();
    return response;
  }

  Future<void> addTask({
    required String title,
    required String description,
    required String category,
    required String time,
    String? date,
    String? fileUrl,
  }) async {

    await supabase.from('tasks').insert({
      'title': title,
      'description': description,
      'category': category,
      'time': time,
      'date': date,
      'file_url': fileUrl,
    });

  }

  Future<String?> uploadFile(String fileName, String filePath) async {
    try {
      final path = 'task_files/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final file = File(filePath);
      await supabase.storage.from('task_files').upload(path, file);
      return supabase.storage.from('task_files').getPublicUrl(path);
    } catch (e) {
      print("Error uploading file: $e");
      return null;
    }
  }

  Future<void> toggleTask(String id, bool value) async {

    await supabase
        .from('tasks')
        .update({'is_completed': value})
        .eq('id', id);

  }

}