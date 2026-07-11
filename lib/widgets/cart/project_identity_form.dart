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
        const Text('Identitas Proyek', style: TextStyle(color: AppColors.mainTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(
          controller: titleController,
          style: const TextStyle(color: AppColors.mainTextColor, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: 'Nama Proyek',
            labelStyle: const TextStyle(color: AppColors.secondaryTextColor),
            filled: true,
            fillColor: AppColors.surfaceColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            prefixIcon: const Icon(Icons.rocket_launch, color: AppColors.primaryColor),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          maxLines: 4,
          style: const TextStyle(color: AppColors.mainTextColor),
          decoration: InputDecoration(
            labelText: 'Deskripsi Cara Kerja',
            labelStyle: const TextStyle(color: AppColors.secondaryTextColor),
            alignLabelWithHint: true,
            filled: true,
            fillColor: AppColors.surfaceColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 60), child: Icon(Icons.description, color: AppColors.primaryColor)),
          ),
        ),
      ],
    );
  }
}