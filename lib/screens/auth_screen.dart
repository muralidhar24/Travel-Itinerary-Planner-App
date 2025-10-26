import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Signup controllers
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureLoginPassword = true;
  bool _obscureSignupPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      animationDuration: const Duration(milliseconds: 300),
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final email = _loginEmailController.text.trim();

      // Check if email is registered
      final isRegistered = await authProvider.isEmailRegistered(email);

      if (!isRegistered) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not registered. Please sign up first.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          // Switch to signup tab with animation
          _tabController.animateTo(1);
          // Pre-fill email in signup form
          _signupEmailController.text = email;
        }
        return;
      }

      try {
        final success = await authProvider.login(
          email,
          _loginPasswordController.text,
        );

        if (success && authProvider.isAuthenticated && mounted) {
          context.go('/home');
        } else if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleSignup() async {
    if (_signupFormKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final email = _signupEmailController.text.trim();

      // Check if email is already registered
      final isRegistered = await authProvider.isEmailRegistered(email);

      if (isRegistered) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email already registered. Please login instead.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          // Switch to login tab with animation
          _tabController.animateTo(0);
          // Pre-fill email in login form
          _loginEmailController.text = email;
        }
        return;
      }

      try {
        final success = await authProvider.signup(
          _signupNameController.text.trim(),
          email,
          _signupPasswordController.text,
        );

        if (success && authProvider.isAuthenticated && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          context.go('/home');
        } else if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Signup failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signup failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color fillColor = theme.colorScheme.surfaceContainerHighest.withOpacity(
      isDark ? 0.25 : 0.7,
    );
    final OutlineInputBorder baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      borderSide: BorderSide(
        color: theme.colorScheme.primary.withOpacity(0.18),
      ),
    );

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor,
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 1.4,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double maxCardWidth = size.width >= 720 ? 520 : size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.authBackgroundGradient,
        ),
        child: Stack(
          children: [
            _buildDecorativeCircle(
              diameter: 260,
              color: Colors.white.withOpacity(0.12),
              left: -90,
              top: -80,
            ),
            _buildDecorativeCircle(
              diameter: 180,
              color: Colors.white.withOpacity(0.08),
              right: -40,
              top: size.height * 0.18,
            ),
            _buildDecorativeCircle(
              diameter: 220,
              color: Colors.white.withOpacity(0.08),
              left: size.width * 0.2,
              bottom: -90,
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxCardWidth),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: AppConstants.paddingLarge),
                        _buildAuthCard(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final Color titleColor = theme.colorScheme.onPrimary;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppConstants.authIconGradient,
            boxShadow: [
              AppConstants.cardShadow,
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.25),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(
            Icons.travel_explore,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Text(
          'Welcome to TravelPlan',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: titleColor,
            fontWeight: FontWeight.bold,
            shadows: const [
              Shadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          'Plan, personalize, and save every detail of your next adventure in one beautiful place.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.85),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthCard(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? null : AppConstants.authCardGradient,
        color: isDark
            ? theme.colorScheme.surface.withOpacity(0.92)
            : null,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        boxShadow: [
          AppConstants.cardShadow,
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.15),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
        border: Border.all(
          color: isDark
              ? theme.colorScheme.primary.withOpacity(0.25)
              : Colors.white.withOpacity(0.12),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.6)
                    : theme.colorScheme.surface.withOpacity(0.35),
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorPadding: const EdgeInsets.all(4),
                labelColor: isDark
                    ? theme.colorScheme.onPrimary
                    : Colors.white,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.65),
                labelStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: theme.textTheme.titleMedium,
                indicator: BoxDecoration(
                  gradient: AppConstants.primaryGradient,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryColor.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                tabs: const [
                  Tab(text: 'Login'),
                  Tab(text: 'Sign Up'),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            AnimatedSize(
              duration: AppConstants.animationMedium,
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: AppConstants.animationMedium,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: _tabController.index == 0
                    ? _buildLoginForm()
                    : _buildSignupForm(),
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Divider(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Why join TravelPlan?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            _buildBenefitChips(context),
            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              'By continuing, you agree to our Terms of Service and Privacy Policy.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitChips(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color backgroundColor = isDark
        ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.12)
        : theme.colorScheme.secondaryContainer.withOpacity(0.65);
    final Color labelColor = isDark
        ? Colors.white.withOpacity(0.9)
        : theme.colorScheme.onSecondaryContainer;

    final benefits = [
      {'label': 'Curated itineraries', 'icon': Icons.auto_awesome_outlined},
      {'label': 'Smart destination insights', 'icon': Icons.lightbulb_outline},
      {'label': 'Collaborative planning', 'icon': Icons.group_outlined},
      {'label': 'Offline access', 'icon': Icons.offline_pin_outlined},
    ];

    return Wrap(
      spacing: AppConstants.paddingSmall,
      runSpacing: AppConstants.paddingSmall,
      alignment: WrapAlignment.center,
      children: benefits
          .map(
            (benefit) => Chip(
              avatar: Icon(
                benefit['icon'] as IconData,
                size: 18,
                color: AppConstants.primaryColor,
              ),
              label: Text(
                benefit['label'] as String,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: backgroundColor,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingSmall,
                vertical: AppConstants.paddingSmall / 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                side: BorderSide(
                  color: AppConstants.primaryColor.withOpacity(0.6),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDecorativeCircle({
    required double diameter,
    required Color color,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Consumer<AuthProvider>(
      key: const ValueKey('login_form'),
      builder: (context, authProvider, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingSmall,
          ),
          child: Form(
            key: _loginFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome back! Access your saved plans instantly.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withOpacity(0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                TextFormField(
                  controller: _loginEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _fieldDecoration(
                    context,
                    label: 'Email',
                    icon: Icons.email_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!Helpers.isValidEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                TextFormField(
                  controller: _loginPasswordController,
                  obscureText: _obscureLoginPassword,
                  decoration: _fieldDecoration(
                    context,
                    label: 'Password',
                    icon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureLoginPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureLoginPassword = !_obscureLoginPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLarge,
                      vertical: AppConstants.paddingMedium,
                    ),
                    elevation: 8,
                    shadowColor: AppConstants.primaryColor.withOpacity(0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLarge),
                    ),
                  ),
                  onPressed: authProvider.isLoading ? null : _handleLogin,
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppConstants.primaryColor,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    // Handle forgot password
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Forgot password feature coming soon!'),
                      ),
                    );
                  },
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignupForm() {
    return Consumer<AuthProvider>(
      key: const ValueKey('signup_form'),
      builder: (context, authProvider, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingSmall,
          ),
          child: Form(
            key: _signupFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create an account to collaborate, sync, and explore smarter.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withOpacity(0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                TextFormField(
                  controller: _signupNameController,
                  decoration: _fieldDecoration(
                    context,
                    label: 'Full Name',
                    icon: Icons.person_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                TextFormField(
                  controller: _signupEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _fieldDecoration(
                    context,
                    label: 'Email',
                    icon: Icons.email_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!Helpers.isValidEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                TextFormField(
                  controller: _signupPasswordController,
                  obscureText: _obscureSignupPassword,
                  decoration: _fieldDecoration(
                    context,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureSignupPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureSignupPassword = !_obscureSignupPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (!Helpers.isValidPassword(value)) {
                      return 'Password must include at least ${AppConstants.minPasswordLength} characters, uppercase, lowercase, number, and special character.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: _fieldDecoration(
                    context,
                    label: 'Confirm Password',
                    icon: Icons.lock_reset_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _signupPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingLarge,
                      vertical: AppConstants.paddingMedium,
                    ),
                    elevation: 8,
                    shadowColor: AppConstants.primaryColor.withOpacity(0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusLarge,
                      ),
                    ),
                  ),
                  onPressed: authProvider.isLoading ? null : _handleSignup,
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppConstants.primaryColor,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    _tabController.animateTo(0);
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

