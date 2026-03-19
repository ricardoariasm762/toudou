import 'package:supabase_flutter/supabase_flutter.dart';

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
  }) async {

    await supabase.from('tasks').insert({
      'title': title,
      'description': description,
      'category': category,
      'time': time,
      'date': date,
    });

  }

  Future<void> toggleTask(String id, bool value) async {

    await supabase
        .from('tasks')
        .update({'is_completed': value})
        .eq('id', id);

  }

}