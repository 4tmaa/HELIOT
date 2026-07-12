import 'package:flutter/material.dart';
import 'package:heliot/utils/app_colors.dart';

class ProjectIdentityForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const ProjectIdentityForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_note_rounded, color: AppColors.primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Identitas Proyek', style: TextStyle(color: AppColors.mainTextColor, fontSize: 17, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: TextFormField(
            controller: titleController,
            style: const TextStyle(color: AppColors.mainTextColor, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              labelText: 'Nama Proyek',
              labelStyle: const TextStyle(color: AppColors.secondaryTextColor),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primaryColor, width: 2)),
              prefixIcon: const Icon(Icons.badge_rounded, color: AppColors.primaryColor),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: TextFormField(
            controller: descriptionController,
            maxLines: 4,
            style: const TextStyle(color: AppColors.mainTextColor, height: 1.5),
            decoration: InputDecoration(
              labelText: 'Deskripsi Cara Kerja',
              labelStyle: const TextStyle(color: AppColors.secondaryTextColor),
              alignLabelWithHint: true,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primaryColor, width: 2)),
              prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 72), child: Icon(Icons.text_snippet_rounded, color: AppColors.primaryColor)),
            ),
          ),
        ),
      ],
    );
  }
}