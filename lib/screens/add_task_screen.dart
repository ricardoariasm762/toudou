import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final service = SupabaseService();

  String category = "Healthy";
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  final categories = ["Healthy", "Design", "Job", "Education", "Sport", "More"];

  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF34C759);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Adding Task",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(titleController, "Task Title", maxLines: 1),
                const SizedBox(height: 20),
                _buildTextField(descController, "Description", isOptional: true, maxLines: 4),
                const SizedBox(height: 24),
                _buildSelectionButton(
                  icon: Icons.calendar_today_outlined,
                  label: "Select Date In Calendar",
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => selectedDate = date);
                  },
                ),
                const SizedBox(height: 16),
                _buildSelectionButton(
                  icon: Icons.add_box_outlined,
                  label: "Additional Files",
                  onTap: () {
                    // Not implemented in this demo
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  "Choose Category",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: categories.map((cat) {
                    final isSelected = category == cat;
                    return GestureDetector(
                      onTap: () => setState(() => category = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSelected ? primaryColor : Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? primaryColor : Colors.grey.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isSaving ? null : () async {
                      if (titleController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter a task title")),
                        );
                        return;
                      }

                      setState(() => isSaving = true);

                      try {
                        // Format time like "8 A.M"
                        final hour = selectedTime.hourOfPeriod == 0 ? 12 : selectedTime.hourOfPeriod;
                        final period = selectedTime.period == DayPeriod.am ? "A.M" : "P.M";
                        final timeStr = "$hour $period";

                        await service.addTask(
                          title: titleController.text,
                          description: descController.text,
                          category: category,
                          time: timeStr,
                          date: DateFormat('yyyy-MM-dd').format(selectedDate),
                        );

                        if (mounted) {
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(() => isSaving = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error saving task: $e")),
                          );
                        }
                      }
                    },
                    child: isSaving 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text(
                          "Confirm Adding",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                  ),
                )
              ],
            ),
          ),
          if (isSaving)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isOptional = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          suffixText: isOptional ? "(Not Required)" : null,
          suffixStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          hintStyle: TextStyle(color: Colors.grey.shade300),
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSelectionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF34C759), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF34C759),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}