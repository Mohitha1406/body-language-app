import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('About App'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // App Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF00E5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF1A73E8).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: const Icon(Icons.accessibility_new_rounded,
                  color: Colors.white, size: 56),
            ),
            const SizedBox(height: 16),
            const Text('Body Language AI',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            const Text('Version 1.0.0',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 4),
            const Text('Analyze. Improve. Confidence.',
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1A73E8),
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 32),

            // Developer Info
            _infoCard(
              icon: Icons.person_rounded,
              title: 'Developer',
              content: 'PAPUDESI MOHITHA\nB.Tech AI & Data Science\nSIMATS School Of Engineering, Chennai',
            ),
            const SizedBox(height: 12),

            // About Project
            _infoCard(
              icon: Icons.info_outline_rounded,
              title: 'About Project',
              content:
                  'AI-Based Body Language Analysis System is a final year project that uses Computer Vision and Artificial Intelligence to analyze body language during presentations and generate a Confidence Score with personalized improvement suggestions.',
            ),
            const SizedBox(height: 12),

            // Tech Stack
            _infoCard(
              icon: Icons.code_rounded,
              title: 'Technology Stack',
              content: '• Flutter (Android App)\n• MediaPipe (AI Pose Estimation)\n• OpenCV (Video Processing)\n• Python FastAPI (Backend)\n• Firebase (Data Storage)',
            ),
            const SizedBox(height: 12),

            // Features
            _infoCard(
              icon: Icons.star_rounded,
              title: 'Key Features',
              content: '• Real camera recording\n• AI body language analysis\n• Confidence Score (0–100%)\n• Personalized feedback\n• Session history tracking\n• Progress monitoring',
            ),
            const SizedBox(height: 12),

            // Contact
            _infoCard(
              icon: Icons.email_outlined,
              title: 'Contact',
              content: 'SIMATS School Of Engineering\nChennai, Tamil Nadu, India\nB.Tech AI & Data Science',
            ),
            const SizedBox(height: 24),

            // Tech pills
            const Text('Built With',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _techPill('Flutter', const Color(0xFF54C5F8)),
                _techPill('MediaPipe', const Color(0xFF FF6F00)),
                _techPill('OpenCV', const Color(0xFF5C8DFF)),
                _techPill('Python', const Color(0xFF3776AB)),
                _techPill('FastAPI', const Color(0xFF009688)),
                _techPill('Firebase', const Color(0xFFFFCA28)),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              '© 2026 PAPUDESI MOHITHA\nAll rights reserved',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1A73E8), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 6),
                Text(content,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _techPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color)),
    );
  }
}