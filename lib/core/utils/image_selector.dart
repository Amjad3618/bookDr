import 'package:bookdr/core/theme/app_colors.dart';
import 'package:bookdr/core/utils/image_croper.dart';
import 'package:flutter/material.dart';
import 'dart:io';

// INTEGRATION EXAMPLE - How to use DoctorProfileImageSection in RegisterViewDr

class RegisterViewDrWithImage extends StatefulWidget {
  const RegisterViewDrWithImage({super.key});

  @override
  State<RegisterViewDrWithImage> createState() =>
      _RegisterViewDrWithImageState();
}

class _RegisterViewDrWithImageState extends State<RegisterViewDrWithImage> {
  // ignore: unused_field
  File? _profileImage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Doctor Registration',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add the profile image section here
              DoctorProfileImageSection(
                onImageSelected: (imageFile) {
                  setState(() => _profileImage = imageFile);
                  print('Profile image selected: ${imageFile.path}');
                },
              ),
              const SizedBox(height: 32),
              // Rest of your registration form goes here
              _buildSectionTitle('Personal Information'),
              // ... rest of your form fields
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
      ),
    );
  }
}