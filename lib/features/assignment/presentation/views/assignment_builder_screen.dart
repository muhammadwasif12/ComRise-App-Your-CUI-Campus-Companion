// import 'package:flutter/material.dart';

// class AssignmentScreen extends StatelessWidget {
//   const AssignmentScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Assignment Builder'),
//         backgroundColor: const Color(0xFFFF6D00),
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             Icon(Icons.assignment, size: 100, color: Color(0xFFFF6D00)),
//             SizedBox(height: 20),
//             Text(
//               'Assignment Builder',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text('Create & manage all your work'),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  List<Map<String, dynamic>> assignments = [
    {
      'title': 'Data Structures Assignment',
      'subject': 'Data Structures',
      'dueDate': '5 Nov 2025',
      'status': 'In Progress',
      'color': const Color(0xFF00C853),
      'progress': 0.6,
    },
    {
      'title': 'OOP Project Report',
      'subject': 'Object Oriented Programming',
      'dueDate': '10 Nov 2025',
      'status': 'Not Started',
      'color': const Color(0xFFFF6D00),
      'progress': 0.0,
    },
    {
      'title': 'Database Lab Report',
      'subject': 'Database Systems',
      'dueDate': '1 Nov 2025',
      'status': 'Completed',
      'color': const Color(0xFF9C27B0),
      'progress': 1.0,
    },
  ];

  int selectedFilter = 0; // 0 = All, 1 = In Progress, 2 = Completed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Assignment Builder'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFFF6D00),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsBar(),
          const SizedBox(height: 16),
          _buildFilterChips(),
          const SizedBox(height: 16),
          Expanded(child: _buildAssignmentList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewAssignment,
        backgroundColor: const Color(0xFFFF6D00),
        icon: const Icon(Icons.add),
        label: const Text('New Assignment'),
      ),
    );
  }

  Widget _buildStatsBar() {
    int total = assignments.length;
    int completed = assignments.where((a) => a['status'] == 'Completed').length;
    int inProgress = assignments
        .where((a) => a['status'] == 'In Progress')
        .length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6D00), Color(0xFF844D17)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6D00).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', total.toString(), Icons.assignment),
          _buildStatDivider(),
          _buildStatItem('In Progress', inProgress.toString(), Icons.pending),
          _buildStatDivider(),
          _buildStatItem('Done', completed.toString(), Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildFilterChip('All', 0, assignments.length),
          const SizedBox(width: 8),
          _buildFilterChip(
            'In Progress',
            1,
            assignments.where((a) => a['status'] == 'In Progress').length,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            'Completed',
            2,
            assignments.where((a) => a['status'] == 'Completed').length,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, int count) {
    bool isSelected = selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF6D00), Color(0xFF844D17)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF6D00).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.3)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentList() {
    List<Map<String, dynamic>> filteredAssignments = selectedFilter == 0
        ? assignments
        : selectedFilter == 1
        ? assignments.where((a) => a['status'] == 'In Progress').toList()
        : assignments.where((a) => a['status'] == 'Completed').toList();

    if (filteredAssignments.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredAssignments.length,
      itemBuilder: (context, index) {
        return _buildAssignmentCard(filteredAssignments[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No assignments found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first assignment',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: assignment['color'].withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openAssignmentEditor(assignment),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: assignment['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.assignment,
                        color: assignment['color'],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            assignment['subject'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(assignment['status']),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Due: ${assignment['dueDate']}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const Spacer(),
                    Text(
                      '${(assignment['progress'] * 100).toInt()}% Complete',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: assignment['color'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: assignment['progress'],
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(assignment['color']),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Completed'
        ? const Color(0xFF00C853)
        : status == 'In Progress'
        ? const Color(0xFFFF6D00)
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _createNewAssignment() {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Create New Assignment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Assignment Title',
                  hintText: 'e.g., Data Structures Assignment',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'e.g., Data Structures',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Due Date',
                  hintText: 'Select date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  subjectController.text.isNotEmpty) {
                Navigator.pop(context);
                _openAssignmentEditor({
                  'title': titleController.text,
                  'subject': subjectController.text,
                  'dueDate': '15 Nov 2025',
                  'status': 'Not Started',
                  'color': const Color(0xFFFF6D00),
                  'progress': 0.0,
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6D00),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Create & Edit'),
          ),
        ],
      ),
    );
  }

  void _openAssignmentEditor(Map<String, dynamic> assignment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignmentEditorScreen(assignment: assignment),
      ),
    );
  }

  void _showFilterOptions() {
    // TODO: Implement advanced filtering
  }
}

// ==========================================
// ASSIGNMENT EDITOR SCREEN (Mini Word Editor)
// ==========================================
class AssignmentEditorScreen extends StatefulWidget {
  final Map<String, dynamic> assignment;

  const AssignmentEditorScreen({super.key, required this.assignment});

  @override
  State<AssignmentEditorScreen> createState() => _AssignmentEditorScreenState();
}

class _AssignmentEditorScreenState extends State<AssignmentEditorScreen> {
  late TextEditingController _contentController;
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  int fontSize = 14;
  TextAlign textAlign = TextAlign.left;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text:
          'Start writing your assignment here...\n\n'
          'You can format text using the toolbar below.',
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.assignment['title']),
        backgroundColor: const Color(0xFFFF6D00),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAssignment,
            tooltip: 'Save',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareAssignment,
            tooltip: 'Share',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Text('Export as DOCX'),
              ),
              const PopupMenuItem(value: 'pdf', child: Text('Export as PDF')),
              const PopupMenuItem(
                value: 'template',
                child: Text('Use Template'),
              ),
            ],
            onSelected: (value) {
              if (value == 'export') _exportAsDocx();
              if (value == 'pdf') _exportAsPdf();
              if (value == 'template') _useTemplate();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFormattingToolbar(),
          Expanded(child: _buildEditor()),
        ],
      ),
    );
  }

  Widget _buildFormattingToolbar() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildToolButton(
              Icons.format_bold,
              isBold,
              () => setState(() => isBold = !isBold),
            ),
            _buildToolButton(
              Icons.format_italic,
              isItalic,
              () => setState(() => isItalic = !isItalic),
            ),
            _buildToolButton(
              Icons.format_underline,
              isUnderline,
              () => setState(() => isUnderline = !isUnderline),
            ),
            _buildDivider(),
            _buildToolButton(
              Icons.format_align_left,
              textAlign == TextAlign.left,
              () => setState(() => textAlign = TextAlign.left),
            ),
            _buildToolButton(
              Icons.format_align_center,
              textAlign == TextAlign.center,
              () => setState(() => textAlign = TextAlign.center),
            ),
            _buildToolButton(
              Icons.format_align_right,
              textAlign == TextAlign.right,
              () => setState(() => textAlign = TextAlign.right),
            ),
            _buildDivider(),
            IconButton(
              icon: const Icon(Icons.text_increase),
              onPressed: () =>
                  setState(() => fontSize = (fontSize + 2).clamp(10, 24)),
            ),
            Text(
              '$fontSize',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.text_decrease),
              onPressed: () =>
                  setState(() => fontSize = (fontSize - 2).clamp(10, 24)),
            ),
            _buildDivider(),
            IconButton(
              icon: const Icon(Icons.list_alt),
              onPressed: () {},
              tooltip: 'Bullet List',
            ),
            IconButton(
              icon: const Icon(Icons.format_list_numbered),
              onPressed: () {},
              tooltip: 'Numbered List',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(IconData icon, bool isActive, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon),
      color: isActive ? const Color(0xFFFF6D00) : Colors.grey[700],
      onPressed: onTap,
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey[300],
    );
  }

  Widget _buildEditor() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _contentController,
        maxLines: null,
        expands: true,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: fontSize.toDouble(),
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          decoration: isUnderline
              ? TextDecoration.underline
              : TextDecoration.none,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Start typing...',
        ),
      ),
    );
  }

  void _saveAssignment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Assignment saved successfully!'),
        backgroundColor: Color(0xFF00C853),
      ),
    );
  }

  void _shareAssignment() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Share feature coming soon!')));
  }

  void _exportAsDocx() {
    // TODO: Export as DOCX using docx package
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Exporting as DOCX...')));
  }

  void _exportAsPdf() {
    // TODO: Export as PDF
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Exporting as PDF...')));
  }

  void _useTemplate() {
    setState(() {
      _contentController.text =
          '''
COMSATS University Islamabad

Assignment Title: ${widget.assignment['title']}
Subject: ${widget.assignment['subject']}
Submitted By: [Your Name]
Roll Number: [Your Roll No]
Date: ${widget.assignment['dueDate']}

---

Introduction:
[Write your introduction here]

Main Content:
[Write your main content here]

Conclusion:
[Write your conclusion here]

References:
[Add your references here]
''';
    });
  }
}
