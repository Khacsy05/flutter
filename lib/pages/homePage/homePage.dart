import 'package:flutter/material.dart';
import 'package:btth1/database/tables.dart';
import 'package:btth1/struct/database_global.dart';
import 'package:btth1/pages/addDocumentPage.dart';
import 'package:btth1/widgets/documentCard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';
  String? _selectedCourseFilter;

  @override
  Widget build(BuildContext context) {
    final courses = appDatabase.getAllCourses();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Quản lý Tài liệu Học tập', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3C72),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên tài liệu, ghi chú...',
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF1E3C72)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Tất cả môn'),
                  selected: _selectedCourseFilter == null,
                  onSelected: (_) => setState(() => _selectedCourseFilter = null),
                ),
                const SizedBox(width: 8),
                ...courses.map((c) {
                  final isSel = _selectedCourseFilter == c.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(c.name),
                      selected: isSel,
                      selectedColor: Color(c.colorValue).withOpacity(0.25),
                      onSelected: (_) {
                        setState(() {
                          _selectedCourseFilter = isSel ? null : c.id;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<StudyDocument>>(
              stream: appDatabase.watchAllDocuments(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!;

                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((d) {
                    return d.title.toLowerCase().contains(_searchQuery) ||
                        d.note.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (_selectedCourseFilter != null) {
                  docs = docs.where((d) => d.courseId == _selectedCourseFilter).toList();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Không tìm thấy tài liệu phù hợp'
                              : 'Chưa có tài liệu nào. Bấm (+) để thêm mới.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final course = courses.firstWhere(
                      (c) => c.id == doc.courseId,
                      orElse: () => Course(id: '', name: 'Môn học', code: '', colorValue: 0xFF1E3C72),
                    );

                    return DocumentCard(
                      doc: doc,
                      course: course,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddDocumentPage(document: doc),
                          ),
                        );
                      },
                      onDelete: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Xác nhận xóa'),
                            content: Text('Bạn có chắc muốn xóa "${doc.title}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('HỦY'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  appDatabase.deleteDocument(doc.id);
                                },
                                child: const Text('XÓA', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1E3C72),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm tài liệu'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDocumentPage()),
          );
        },
      ),
    );
  }
}
