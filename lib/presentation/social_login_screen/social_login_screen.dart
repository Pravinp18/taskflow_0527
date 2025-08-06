import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SocialLoginScreen extends StatefulWidget {
  const SocialLoginScreen({Key? key}) : super(key: key);

  @override
  State<SocialLoginScreen> createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends State<SocialLoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isFacebookLoading = false;
  bool _isTwitterLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Mock credentials for testing
  final Map<String, Map<String, String>> _mockCredentials = {
    'google': {
      'email': 'user@gmail.com',
      'password': 'google123',
    },
    'apple': {
      'email': 'user@icloud.com',
      'password': 'apple123',
    },
    'facebook': {
      'email': 'user@facebook.com',
      'password': 'facebook123',
    },
    'twitter': {
      'email': 'user@twitter.com',
      'password': 'twitter123',
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() {
      _errorMessage = null;
      switch (provider) {
        case 'google':
          _isGoogleLoading = true;
          break;
        case 'apple':
          _isAppleLoading = true;
          break;
        case 'facebook':
          _isFacebookLoading = true;
          break;
        case 'twitter':
          _isTwitterLoading = true;
          break;
      }
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock authentication logic
      final credentials = _mockCredentials[provider];
      if (credentials != null) {
        // Simulate successful authentication
        if (mounted) {
          // Trigger haptic feedback
          HapticFeedback.lightImpact();

          // Navigate to task list screen with fade transition
          Navigator.pushReplacementNamed(context, '/task-list-screen');
        }
      } else {
        throw Exception('Authentication failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(provider, e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
          _isAppleLoading = false;
          _isFacebookLoading = false;
          _isTwitterLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String provider, dynamic error) {
    // Mock different error scenarios
    final errorMessages = [
      'Network connection failed. Please check your internet connection.',
      '$provider authentication service is temporarily unavailable.',
      'Authentication failed. Please try again.',
      'Account access restricted. Please contact support.',
    ];

    return errorMessages[DateTime.now().millisecond % errorMessages.length];
  }

  Widget _buildLogo() {
    return Container(
      width: 25.w,
      height: 25.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'TF',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        Text(
          'Welcome to TaskFlow',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        Text(
          'Sign in quickly and securely with your favorite social account to start organizing your tasks.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String provider,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required String iconName,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 6.h,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: ElevatedButton(
        onPressed: isLoading || _isAnyLoading() ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: provider == 'google'
                ? BorderSide(color: AppTheme.lightTheme.colorScheme.outline)
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
        ),
        child: isLoading
            ? SizedBox(
                width: 5.w,
                height: 5.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: iconName,
                    color: textColor,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  bool _isAnyLoading() {
    return _isGoogleLoading ||
        _isAppleLoading ||
        _isFacebookLoading ||
        _isTwitterLoading;
  }

  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      margin: EdgeInsets.symmetric(vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'error_outline',
            color: AppTheme.lightTheme.colorScheme.error,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeOptions() {
    return Column(
      children: [
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Having trouble?',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline,
                thickness: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        TextButton(
          onPressed: () {
            setState(() {
              _errorMessage = null;
            });
          },
          child: Text(
            'Try again',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8.h),

                  // App Logo
                  _buildLogo(),

                  SizedBox(height: 6.h),

                  // Welcome Message
                  _buildWelcomeMessage(),

                  SizedBox(height: 6.h),

                  // Social Login Buttons
                  _buildSocialButton(
                    provider: 'google',
                    label: 'Continue with Google',
                    backgroundColor: Colors.white,
                    textColor: AppTheme.lightTheme.colorScheme.onSurface,
                    iconName: 'g_translate',
                    isLoading: _isGoogleLoading,
                    onPressed: () => _handleSocialLogin('google'),
                  ),

                  // Apple Sign In (iOS only)
                  if (defaultTargetPlatform == TargetPlatform.iOS || kIsWeb)
                    _buildSocialButton(
                      provider: 'apple',
                      label: 'Continue with Apple',
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      iconName: 'apple',
                      isLoading: _isAppleLoading,
                      onPressed: () => _handleSocialLogin('apple'),
                    ),

                  _buildSocialButton(
                    provider: 'facebook',
                    label: 'Continue with Facebook',
                    backgroundColor: const Color(0xFF1877F2),
                    textColor: Colors.white,
                    iconName: 'facebook',
                    isLoading: _isFacebookLoading,
                    onPressed: () => _handleSocialLogin('facebook'),
                  ),

                  _buildSocialButton(
                    provider: 'twitter',
                    label: 'Continue with Twitter',
                    backgroundColor: const Color(0xFF1DA1F2),
                    textColor: Colors.white,
                    iconName: 'alternate_email',
                    isLoading: _isTwitterLoading,
                    onPressed: () => _handleSocialLogin('twitter'),
                  ),

                  // Error Message
                  _buildErrorMessage(),

                  // Alternative Options
                  _buildAlternativeOptions(),

                  SizedBox(height: 4.h),

                  // Terms and Privacy
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
