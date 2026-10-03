import 'package:flutter/material.dart';
import 'package:btth1/database/tables.dart';
import 'package:btth1/struct/database_global.dart';
import 'package:btth1/struct/document_enums.dart';

class AddDocumentPage extends StatefulWidget {
  final StudyDocument? document;

  const AddDocumentPage({super.key, this.document});

  @override
  State<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late TextEditingController _filePathController;

  late String _selectedCourseId;
  late DocumentType _selectedType;
  late ReadStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    final doc = widget.document;
    _titleController = TextEditingController(text: doc?.title ?? '');
    _noteController = TextEditingController(text: doc?.note ?? '');
    _filePathController = TextEditingController(text: doc?.filePath ?? '');

    final courses = appDatabase.getAllCourses();
    _selectedCourseId = doc?.courseId ?? (courses.isNotEmpty ? courses.first.id : '1');
    _selectedType = doc?.type ?? DocumentType.lecture;
    _selectedStatus = doc?.status ?? ReadStatus.unread;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _filePathController.dispose();
    super.dispose();
  }

  void _saveDocument() {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.document != null;
    final now = DateTime.now();

    final docToSave = StudyDocument(
      id: isEdit ? widget.document!.id : 'doc_',
      title: _titleController.text.trim(),
      courseId: _selectedCourseId,
      filePath: _filePathController.text.trim().isEmpty ? null : _filePathController.text.trim(),
      note: _noteController.text.trim(),
      type: _selectedType,
      status: _selectedStatus,
      dateCreated: isEdit ? widget.document!.dateCreated : now,
      dateTimeModified: now,
    );

    if (isEdit) {
      appDatabase.updateDocument(docToSave);
    } else {
      appDatabase.insertDocument(docToSave);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final courses = appDatabase.getAllCourses();
    final isEdit = widget.document != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa Tài liệu' : 'Thêm Tài liệu mới', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3C72),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề tài liệu *',
                  hintText: 'Nhập tên tài liệu, slide, bài tập...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.title_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập tiêu đề tài liệu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCourseId,
                decoration: InputDecoration(
                  labelText: 'Môn học / Học phần *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.school_rounded),
                ),
                items: courses.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCourseId = val);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<DocumentType>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Phân loại',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: DocumentType.lecture, child: Text('Bài giảng')),
                        DropdownMenuItem(value: DocumentType.assignment, child: Text('Bài tập')),
                        DropdownMenuItem(value: DocumentType.reference, child: Text('Tham khảo')),
                        DropdownMenuItem(value: DocumentType.exam, child: Text('Đề thi')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedType = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<ReadStatus>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Trạng thái',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: ReadStatus.unread, child: Text('Chưa đọc')),
                        DropdownMenuItem(value: ReadStatus.reading, child: Text('Đang đọc')),
                        DropdownMenuItem(value: ReadStatus.completed, child: Text('Đã xong')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatus = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _filePathController,
                decoration: InputDecoration(
                  labelText: 'Đường dẫn tệp / URL Drive',
                  hintText: 'https://drive.google.com/... hoặc /storage/...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.link_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Ghi chú tóm tắt',
                  hintText: 'Nhập nội dung lưu ý, hạn chót...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.note_alt_rounded),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveDocument,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3C72),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.save_rounded),
                label: Text(isEdit ? 'LƯU THAY ĐỔI' : 'THÊM TÀI LIỆU', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
