import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:share_plus/share_plus.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/theme_colors.dart';
import '../providers/datesheet_provider.dart';
import '../../data/models/exam_model.dart';

class DatesheetScreen extends ConsumerStatefulWidget {
  const DatesheetScreen({super.key});

  @override
  ConsumerState<DatesheetScreen> createState() => _DatesheetScreenState();
}

class _DatesheetScreenState extends ConsumerState<DatesheetScreen> {
  bool _isParsing = false;

  Future<void> _pickAndParseFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        _showBatchSectionDialog(path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  void _showBatchSectionDialog(String filePath) {
    final batchController = TextEditingController();
    final sectionController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Filter Details',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your batch and section to filter the datesheet.',
              style: GoogleFonts.rubik(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: batchController,
              decoration: InputDecoration(
                hintText: 'e.g. FA21, SP22',
                labelText: 'Batch',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: sectionController,
              decoration: InputDecoration(
                hintText: 'e.g. BSE-3A, BCS-5B',
                labelText: 'Section',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final batch = batchController.text.trim().toUpperCase();
              final section = sectionController.text.trim().toUpperCase();
              if (batch.isEmpty || section.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              Navigator.pop(context);
              _processFile(filePath, batch, section);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Process'),
          ),
        ],
      ),
    );
  }

  Future<void> _processFile(String path, String batch, String section) async {
    setState(() => _isParsing = true);
    try {
      final bytes = File(path).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      List<ExamEntry> exams = [];

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null) continue;

        // Simple heuristic parsing
        // We look for rows that contain both batch and section
        for (var row in sheet.rows) {
          final rowData = row
              .map((cell) => cell?.value?.toString().toUpperCase() ?? '')
              .toList();

          bool hasBatch = rowData.any((cell) => cell.contains(batch));
          bool hasSection = rowData.any((cell) => cell.contains(section));

          if (hasBatch && hasSection) {
            // Found a matching row!
            // Now attempt to Map it. This is tricky as formats change.
            // We'll try to find Date, Time, Room, Subject based on typical positions or keywords.

            // For now, let's assume a semi-standard format or just save the whole row data conceptually
            // In a real app, we'd need more robust mapping or user mapping UI.
            // Let's try some common indices (this is a guess for CUI xls)
            // Date is usually at index 0 or 1, Time at 2, Subject at 3-5, Room at last or near last.

            // Mapping (Rough guide for CUI Sahiwal/Lahore formats)
            final entry = ExamEntry(
              date:
                  _findHeuristic(rowData, ['DATE', '/202', '2025', '2024']) ??
                  'N/A',
              day:
                  _findHeuristic(rowData, [
                    'MONDAY',
                    'TUESDAY',
                    'WEDNESDAY',
                    'THURSDAY',
                    'FRIDAY',
                    'SATURDAY',
                    'SUNDAY',
                  ]) ??
                  '',
              time:
                  _findHeuristic(rowData, ['AM', 'PM', '09:', '01:', '02:']) ??
                  'N/A',
              course:
                  _findHeuristic(rowData, ['SUBJECT', 'COURSE', 'TITLE']) ??
                  _getCourseGuess(rowData),
              batch: batch,
              section: section,
              room: _findHeuristic(rowData, ['ROOM', 'LAB', 'HALL']) ?? 'N/A',
            );
            exams.add(entry);
          }
        }
      }

      if (exams.isEmpty) {
        throw Exception('No matching records found for $batch $section');
      }

      await ref.read(datesheetProvider.notifier).saveDatesheet(exams);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported ${exams.length} exams!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error parsing datesheet: $e')));
      }
    } finally {
      if (mounted) setState(() => _isParsing = false);
    }
  }

  String? _findHeuristic(List<String> row, List<String> keywords) {
    for (var cell in row) {
      for (var kw in keywords) {
        if (cell.contains(kw)) return cell;
      }
    }
    return null;
  }

  String _getCourseGuess(List<String> row) {
    // Usually the longest string that isn't a date/time/room is the course name
    String longest = 'N/A';
    for (var cell in row) {
      if (cell.length > longest.length &&
          !cell.contains(':') &&
          !cell.contains('/20') &&
          cell.length > 5) {
        longest = cell;
      }
    }
    return longest;
  }

  void _shareDatesheet(List<ExamEntry> exams) {
    if (exams.isEmpty) return;

    String text = "📅 *My Exam Datesheet*\n\n";
    for (var exam in exams) {
      text += "📖 *${exam.course}*\n";
      text += "🗓 Date: ${exam.date} (${exam.day})\n";
      text += "⏰ Time: ${exam.time}\n";
      text += "📍 Room: ${exam.room}\n";
      text += "------------------\n";
    }
    text += "\nShared via *ComRise CUI*";

    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final datesheetAsync = ref.watch(datesheetProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datesheet',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Exam Schedule',
              style: GoogleFonts.rubik(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppColors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              datesheetAsync.whenData((exams) {
                if (exams.isNotEmpty) _shareDatesheet(exams);
              });
            },
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share WhatsApp',
          ),
          IconButton(
            onPressed: () {
              ref.read(datesheetProvider.notifier).clearDatesheet();
            },
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear',
          ),
        ],
      ),
      body: Stack(
        children: [
          datesheetAsync.when(
            data: (exams) {
              if (exams.isEmpty) {
                return Center(
                  child: FadeInUp(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload_file_rounded,
                          size: 80,
                          color: AppColors.deepPurple.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No datesheet found',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Upload your university XLS file to get your personalized exam schedule.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rubik(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: _pickAndParseFile,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Upload XLS'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final exam = exams[index];
                  return FadeInLeft(
                    delay: Duration(milliseconds: 100 * index),
                    child: _buildExamCard(exam, isDark),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.deepPurple),
            ),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
          if (_isParsing)
            Container(
              color: Colors.black45,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 20),
                    Text(
                      'Parsing Excel file...',
                      style: GoogleFonts.rubik(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: datesheetAsync.maybeWhen(
        data: (exams) => exams.isNotEmpty
            ? FloatingActionButton(
                onPressed: _pickAndParseFile,
                backgroundColor: AppColors.deepPurple,
                child: const Icon(Icons.file_upload_rounded),
              )
            : null,
        orElse: () => null,
      ),
    );
  }

  Widget _buildExamCard(ExamEntry exam, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 80,
                color: AppColors.deepPurple.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      exam.date.split('/').first,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepPurple,
                      ),
                    ),
                    Text(
                      exam.day.substring(0, 3).toUpperCase(),
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepPurple.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.course,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            exam.time,
                            style: GoogleFonts.rubik(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            exam.room,
                            style: GoogleFonts.rubik(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${exam.batch} - ${exam.section}',
                        style: GoogleFonts.rubik(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.deepPurple.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
