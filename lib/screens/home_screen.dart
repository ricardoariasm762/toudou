import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../models/task.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service = SupabaseService();
  List<Task> allTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    setState(() => isLoading = true);
    try {
      final data = await service.getTasks();
      final List<Task> fetchedTasks = data.map((t) => Task.fromJson(t)).toList();
      
      setState(() {
        allTasks = fetchedTasks;
        // Ordenar por ID descendente para que las más nuevas estén arriba
        allTasks.sort((a, b) => b.id.compareTo(a.id)); 
        isLoading = false;
      });
    } catch (e) {
      print("Error loading tasks: $e");
      setState(() => isLoading = false);
    }
  }

  bool _isSameDay(String? dateStr1, String dateStr2) {
    if (dateStr1 == null) return false;
    try {
      final d1 = DateTime.parse(dateStr1);
      final d2 = DateTime.parse(dateStr2);
      return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
    } catch (e) {
      return dateStr1 == dateStr2;
    }
  }

  List<Task> get todayTasks {
    // Para asegurar que siempre veas las tareas al crearlas, mostramos todas
    // las tareas registradas en la lista principal.
    return allTasks;
  }

  List<Task> get weeklyTasks {
    final now = DateTime.now();
    // Obtener el lunes de esta semana
    final firstDayOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    // Obtener el domingo de esta semana
    final lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59));

    return allTasks.where((t) {
      // Si no tiene fecha, la incluimos en el conteo semanal para no perderla
      if (t.date == null || t.date!.isEmpty) return true;
      try {
        final taskDate = DateTime.parse(t.date!);
        return taskDate.isAfter(firstDayOfWeek.subtract(const Duration(seconds: 1))) &&
            taskDate.isBefore(lastDayOfWeek.add(const Duration(seconds: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  double get todayProgress {
    if (todayTasks.isEmpty) return 0;
    int completed = todayTasks.where((t) => t.isCompleted).length;
    return completed / todayTasks.length;
  }

  double get weeklyProgress {
    if (weeklyTasks.isEmpty) return 0;
    int completed = weeklyTasks.where((t) => t.isCompleted).length;
    return completed / weeklyTasks.length;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF34C759);
    final currentTodayTasks = todayTasks;
    final currentWeeklyTasks = weeklyTasks;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 🔥 WEEKLY TASKS CARD
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            value: weeklyProgress,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.shade100,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          "${(weeklyProgress * 100).toInt()}%",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF34C759),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Weekly Tasks",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3142),
                                ),
                              ),
                              Icon(Icons.arrow_forward, size: 20, color: Colors.grey.shade400),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildTaskCount("${currentWeeklyTasks.where((t) => !t.isCompleted).length}", Colors.white, primaryColor, true),
                              const SizedBox(width: 12),
                              _buildTaskCount("${currentWeeklyTasks.where((t) => t.isCompleted).length}", Colors.white, Colors.redAccent, false),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // 🔥 TODAY TASKS HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today Tasks",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  Text(
                    "${currentTodayTasks.where((t) => t.isCompleted).length} of ${currentTodayTasks.length}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: todayProgress,
                  minHeight: 10,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              // 🔥 LISTA DE TAREAS
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : currentTodayTasks.isEmpty
                        ? const Center(child: Text("No tasks for today"))
                        : ListView.builder(
                            itemCount: currentTodayTasks.length,
                            padding: const EdgeInsets.only(bottom: 20),
                            itemBuilder: (context, index) {
                              final task = currentTodayTasks[index];
                              return _buildTaskItem(task, primaryColor);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(primaryColor),
    );
  }

  Widget _buildTaskCount(String count, Color bgColor, Color textColor, bool isPrimary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        count,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              await service.toggleTask(task.id, !task.isCompleted);
              loadTasks();
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: task.isCompleted ? primaryColor.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: task.isCompleted ? primaryColor : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? Icon(Icons.check, size: 18, color: primaryColor)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3142),
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (task.fileUrl != null && task.fileUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.attach_file, size: 14, color: primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          "Attached File",
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  task.time,
                  style: const TextStyle(
                    color: Color(0xFFFFD15B),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              if (task.fileUrl != null && task.fileUrl!.isNotEmpty)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.visibility_outlined, size: 20, color: Colors.grey.shade400),
                  onPressed: () {
                    // Aquí podrías usar url_launcher para abrir el archivo
                    // showDialog o abrir una nueva pantalla para ver la imagen
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.home_filled, color: primaryColor, size: 28),
          Icon(Icons.assignment_outlined, color: Colors.grey.shade400, size: 28),
          Icon(Icons.pie_chart_outline, color: Colors.grey.shade400, size: 28),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTaskScreen()),
              );
              loadTasks();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}