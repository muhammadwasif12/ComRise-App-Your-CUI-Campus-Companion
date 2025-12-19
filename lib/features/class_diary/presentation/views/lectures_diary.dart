import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  int selectedSubjectIndex = 0; // 0 = All subjects

  final List<String> subjects = [
    'All Subjects',
    'Data Structures',
    'Operating Systems',
    'Database Systems',
    'OOP',
    'Web Development',
    'Mobile App Dev',
  ];

  List<Map<String, dynamic>> notes = [
    {
      'id': 1,
      'subject': 'Data Structures',
      'title': 'Binary Trees - Complete Guide',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'content':
          'Binary Tree is a hierarchical data structure...\n\nTypes:\n1. Full Binary Tree\n2. Complete Binary Tree\n3. Perfect Binary Tree\n\nOperations: Insert, Delete, Traverse (Inorder, Preorder, Postorder)',
      'color': const Color(0xFF00C853),
      'isPinned': true,
      'tags': ['Important', 'Exam'],
    },
    {
      'id': 2,
      'subject': 'Operating Systems',
      'title': 'Process Scheduling Algorithms',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'content':
          'CPU Scheduling algorithms:\n\n1. FCFS (First Come First Serve)\n2. SJF (Shortest Job First)\n3. Priority Scheduling\n4. Round Robin\n5. Multilevel Queue',
      'color': const Color(0xFF9C27B0),
      'isPinned': false,
      'tags': ['Lab', 'Quiz'],
    },
    {
      'id': 3,
      'subject': 'Database Systems',
      'title': 'SQL Queries & Joins',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'content':
          'SQL Join Types:\n\n1. INNER JOIN\n2. LEFT JOIN\n3. RIGHT JOIN\n4. FULL OUTER JOIN\n5. CROSS JOIN\n\nExample: SELECT * FROM students INNER JOIN courses ON students.id = courses.student_id',
      'color': const Color(0xFFFF6D00),
      'isPinned': true,
      'tags': ['Assignment'],
    },
    {
      'id': 4,
      'subject': 'OOP',
      'title': 'Object-Oriented Programming Concepts',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'content':
          'Four Pillars of OOP:\n\n1. Encapsulation - Data hiding\n2. Inheritance - Code reusability\n3. Polymorphism - Multiple forms\n4. Abstraction - Hiding complexity',
      'color': const Color(0xFF2196F3),
      'isPinned': false,
      'tags': ['Theory'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredNotes {
    List<Map<String, dynamic>> filtered = notes;

    // Filter by subject
    if (selectedSubjectIndex != 0) {
      filtered = filtered
          .where((note) => note['subject'] == subjects[selectedSubjectIndex])
          .toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((note) {
        return note['title'].toLowerCase().contains(
              searchQuery.toLowerCase(),
            ) ||
            note['content'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            note['subject'].toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Separate pinned notes
    List<Map<String, dynamic>> pinned = filtered
        .where((note) => note['isPinned'] == true)
        .toList();
    List<Map<String, dynamic>> unpinned = filtered
        .where((note) => note['isPinned'] == false)
        .toList();

    return [...pinned, ...unpinned];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Class Diary'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(children: [_buildSearchBar(), _buildTabBar()]),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildNotesTab(), _buildSubjectsTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNoteDialog,
        backgroundColor: const Color(0xFF00C853),
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => searchQuery = value),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search notes, subjects...',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF00C853),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'All Notes', icon: Icon(Icons.note, size: 20)),
          Tab(text: 'By Subject', icon: Icon(Icons.folder, size: 20)),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    final displayNotes = filteredNotes;

    return Column(
      children: [
        _buildStatsBar(),
        Expanded(
          child: displayNotes.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: displayNotes.length,
                  itemBuilder: (context, index) {
                    return _buildNoteCard(displayNotes[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    int totalNotes = notes.length;
    int pinnedNotes = notes.where((n) => n['isPinned'] == true).length;
    int subjectsCount = notes.map((n) => n['subject']).toSet().length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C853), Color(0xFF2C630A)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C853).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.note, 'Total Notes', totalNotes.toString()),
          _buildStatDivider(),
          _buildStatItem(Icons.push_pin, 'Pinned', pinnedNotes.toString()),
          _buildStatDivider(),
          _buildStatItem(Icons.book, 'Subjects', subjectsCount.toString()),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
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

  Widget _buildSubjectsTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(
              subjects.length,
              (index) => _buildSubjectChip(subjects[index], index),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: filteredNotes.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    return _buildNoteCard(filteredNotes[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSubjectChip(String subject, int index) {
    bool isSelected = selectedSubjectIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedSubjectIndex = index),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF2C630A)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : const Color(0xFF00C853).withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF00C853).withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          subject,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.bookOpen, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            searchQuery.isNotEmpty ? 'No notes found' : 'No Notes Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? 'Try different keywords'
                : 'Start adding your lecture notes',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: note['color'].withOpacity(0.3)),
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
          onTap: () => _showNoteDetails(note),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: note['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.book, size: 14, color: note['color']),
                          const SizedBox(width: 4),
                          Text(
                            note['subject'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: note['color'],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (note['isPinned'])
                      const Icon(
                        Icons.push_pin,
                        size: 18,
                        color: Color(0xFFFF6D00),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(note['date']),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  note['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  note['content'],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (note['tags'] as List<String>).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'View full note',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onPressed: () => _showNoteOptions(note),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  void _showAddNoteDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedSubject = subjects[1];
    List<String> selectedTags = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Add New Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedSubject,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.book),
                  ),
                  items: subjects.skip(1).map((subject) {
                    return DropdownMenuItem(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setDialogState(() => selectedSubject = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g., Binary Trees',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Write your notes here...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tags:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      [
                        'Important',
                        'Exam',
                        'Lab',
                        'Quiz',
                        'Assignment',
                        'Theory',
                      ].map((tag) {
                        bool isSelected = selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                selectedTags.add(tag);
                              } else {
                                selectedTags.remove(tag);
                              }
                            });
                          },
                          selectedColor: const Color(
                            0xFF00C853,
                          ).withOpacity(0.3),
                        );
                      }).toList(),
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
                    contentController.text.isNotEmpty) {
                  setState(() {
                    notes.insert(0, {
                      'id': notes.length + 1,
                      'subject': selectedSubject,
                      'title': titleController.text,
                      'date': DateTime.now(),
                      'content': contentController.text,
                      'color': const Color(0xFF00C853),
                      'isPinned': false,
                      'tags': selectedTags,
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note added successfully!'),
                      backgroundColor: Color(0xFF00C853),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDetails(Map<String, dynamic> note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailsScreen(note: note)),
    );
  }

  void _showNoteOptions(Map<String, dynamic> note) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                note['isPinned'] ? Icons.push_pin_outlined : Icons.push_pin,
              ),
              title: Text(note['isPinned'] ? 'Unpin' : 'Pin to top'),
              onTap: () {
                setState(() => note['isPinned'] = !note['isPinned']);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      note['isPinned'] ? 'Note pinned' : 'Note unpinned',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _showNoteDetails(note);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                setState(() => notes.remove(note));
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Note deleted')));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// NOTE DETAILS SCREEN
// ==========================================
class NoteDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> note;

  const NoteDetailsScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Note Details'),
        backgroundColor: note['color'],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Open edit screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Share note
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: note['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          note['subject'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: note['color'],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('MMM dd, yyyy').format(note['date']),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    note['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    note['content'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (note['tags'] as List<String>).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: note['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: note['color'],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
