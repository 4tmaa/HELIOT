import 'package:flutter/material.dart';
import 'package:heliot/utils/app_colors.dart';

class ProjectIdentityForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController userNameController;
  final TextEditingController userEmailController;
  final TextEditingController userPhoneController;

  const ProjectIdentityForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.userNameController,
    required this.userEmailController,
    required this.userPhoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Data Pemesan',
              style: TextStyle(
                color: AppColors.mainTextColor,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
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
              ),
            ],
          ),
          child: TextFormField(
            controller: userNameController,
            style: const TextStyle(
              color: AppColors.mainTextColor,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              labelText: 'Nama Lengkap',
              labelStyle: const TextStyle(color: AppColors.secondaryTextColor),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
              ),
              prefixIcon: const Icon(
                Icons.person_rounded,
                color: AppColors.primaryColor,
              ),
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
              ),
            ],
          ),
          child: TextFormField(
            controller: userEmailController,
            style: const TextStyle(
              color: AppColors.mainTextColor,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              labelText: 'Alamat Email',
              labelStyle: const TextStyle(color: AppColors.secondaryTextColor),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
              ),
              prefixIcon: const Icon(
                Icons.email_rounded,
                color: AppColors.primaryColor,
              ),
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
              ),
            ],
          ),
          child: TextFormField(
            controller: userPhoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(
              color: AppColors.mainTextColor,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              labelText: 'Nomor Telepon / WhatsApp',
              labelStyle: const TextStyle(color: AppColors.secondaryTextColor),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
              ),
              prefixIcon: const Icon(
                Icons.phone_rounded,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Divider(height: 1, color: Color(0xFFEEEEEE), thickness: 2),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text(
              'Identitas Proyek',
              style: TextStyle(
                color: AppColors.mainTextColor,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
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
              ),
            ],
          ),
          child: TextFormField(
            controller: titleController,
            style: const TextStyle(
              color: AppColors.mainTextColor,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              labelText: 'Nama Proyek',
              labelStyle: const TextStyle(color: AppColors.secondaryTextColor),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
              ),
              prefixIcon: const Icon(
                Icons.badge_rounded,
                color: AppColors.primaryColor,
              ),
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
              ),
            ],
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
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 72),
                child: Icon(
                  Icons.text_snippet_rounded,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
