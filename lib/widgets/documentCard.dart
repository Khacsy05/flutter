import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:btth1/database/tables.dart';
import 'package:btth1/struct/document_enums.dart';

class DocumentCard extends StatelessWidget {
  final StudyDocument doc;
  final Course? course;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DocumentCard({
    super.key,
    required this.doc,
    this.course,
    this.onTap,
    this.onDelete,
  });

  String _getTypeLabel(DocumentType type) {
    switch (type) {
      case DocumentType.lecture:
        return 'Bài giảng';
      case DocumentType.assignment:
        return 'Bài tập';
      case DocumentType.reference:
        return 'Tham khảo';
      case DocumentType.exam:
        return 'Đề thi';
    }
  }

  Color _getStatusColor(ReadStatus status) {
    switch (status) {
      case ReadStatus.completed:
        return Colors.green;
      case ReadStatus.reading:
        return Colors.orange;
      case ReadStatus.unread:
        return Colors.grey;
    }
  }

  String _getStatusLabel(ReadStatus status) {
    switch (status) {
      case ReadStatus.completed:
        return 'Đã xong';
      case ReadStatus.reading:
        return 'Đang đọc';
      case ReadStatus.unread:
        return 'Chưa đọc';
    }
  }

  Future<void> _openLink(BuildContext context, String rawUrl) async {
    String formattedUrl = rawUrl.trim();
    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://';
    }

    final uri = Uri.tryParse(formattedUrl);
    if (uri != null) {
      try {
        final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!success) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Không thể mở liên kết: ')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi mở liên kết: ')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseColor = Color(course?.colorValue ?? 0xFF1E3C72);
    final hasFilePath = doc.filePath != null && doc.filePath!.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: courseColor.withOpacity(0.3), width: 1.2),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HÀNG 1: BADGE TÊN MÔN HỌC + BADGE LOẠI TÀI LIỆU + NÚT XÓA
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: courseColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          course?.name ?? 'Môn học',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      _getTypeLabel(doc.type),
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // HÀNG 2: TIÊU ĐỀ TÀI LIỆU
              Text(
                doc.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 6),

              // HÀNG 3: GHI CHÚ
              if (doc.note.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes_rounded, size: 15, color: Colors.grey.shade600),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        doc.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // HÀNG 4: KHỐI LIÊN KẾT CÓ THỂ CLICK VÀO ĐỂ MỞ URL TRỰC TIẾP
              if (hasFilePath) ...[
                Material(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _openLink(context, doc.filePath!),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.open_in_new_rounded, size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              doc.filePath!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Mở link',
                              style: TextStyle(color: Colors.blue.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // HÀNG 5: TRẠNG THÁI ĐỌC
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(doc.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getStatusLabel(doc.status),
                    style: TextStyle(
                      color: _getStatusColor(doc.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
