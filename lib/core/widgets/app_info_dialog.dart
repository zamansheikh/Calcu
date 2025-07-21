import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfoDialog extends StatelessWidget {
  const AppInfoDialog({super.key});

  // Get version from pubspec (you can update this manually or use a build script)
  static const String _version = '3.7.0';
  static const String _buildNumber = '1';

  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        HapticFeedback.lightImpact();
      } else {
        _showErrorSnackBar('Could not launch $url', context);
      }
    } catch (e) {
      _showErrorSnackBar('Error launching URL', context);
    }
  }

  void _showErrorSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.inversePrimary,
            size: 28.sp,
          ),
          SizedBox(width: 12.sp),
          Expanded(
            child: Text(
              'Calcu App Features',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height *
              0.7, // Limit height to 70% of screen
          maxWidth:
              MediaQuery.of(context).size.width *
              0.85, // Limit width for better visibility
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 16.sp),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Version
                Container(
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.apps,
                        color: Theme.of(context).colorScheme.inversePrimary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.sp),
                      Text(
                        'Version $_version+$_buildNumber',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.sp),

                // Key Features Title
                Text(
                  '✨ Key Features:',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 12.sp),

                ..._buildFeatureList(context),

                SizedBox(height: 20.sp),

                // Developer Section
                Text(
                  '👨‍💻 Developer:',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8.sp),

                Text(
                  'Zaman Sheikh',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 12.sp),

                // Links Section
                _buildClickableLink(
                  'GitHub Profile',
                  'https://github.com/zamansheikh',
                  Icons.code,
                  context,
                ),

                SizedBox(height: 8.sp),

                _buildClickableLink(
                  'Email Developer',
                  'mailto:decodersfamily@gmail.com',
                  Icons.email,
                  context,
                ),

                SizedBox(height: 16.sp),

                // Thanks section
                Text(
                  '🙏 Thank you for using Calcu!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 14.sp,
                  ),
                ),

                SizedBox(height: 12.sp),

                // Made with love
                Center(
                  child: Text(
                    'Made with ❤️ in Bangladesh 🇧🇩',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            HapticFeedback.heavyImpact();
          },
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 10.sp),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.sp),
            ),
          ),
          child: Text(
            'Got It!',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFeatureList(BuildContext context) {
    final features = [
      '🧮 Advanced Mathematical Operations',
      '📱 Google Calculator-style Cursor Navigation',
      '👆 Tap anywhere to position cursor for editing',
      '💾 Long-press Result/Input to save values',
      '🎯 Long-press "=" for 3 decimal precision',
      '📊 Long-press "%" to reveal remainder',
      '🔢 Auto-calculation as you type',
      '💨 Responsive design with smooth animations',
      '🌙 Dark/Light theme support',
      '📋 Memory functions for saved calculations',
      '🔄 Smart expression validation',
      '⚡ Haptic feedback for better UX',
    ];

    return features
        .map(
          (feature) => Padding(
            padding: EdgeInsets.only(bottom: 6.sp, left: 8.sp),
            child: Text(
              feature,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 14.sp,
                height: 1.3,
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildClickableLink(
    String text,
    String url,
    IconData icon,
    BuildContext context,
  ) {
    return InkWell(
      onTap: () => _launchUrl(url, context),
      borderRadius: BorderRadius.circular(8.sp),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 16.sp),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.inversePrimary.withValues(alpha: 0.15),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.inversePrimary.withValues(alpha: 0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12.sp),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.inversePrimary,
              size: 20.sp,
            ),
            SizedBox(width: 12.sp),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: Theme.of(context).colorScheme.inversePrimary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
