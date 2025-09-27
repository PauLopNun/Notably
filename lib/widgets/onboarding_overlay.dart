import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onCompleted;

  const OnboardingOverlay({
    super.key,
    required this.child,
    this.onCompleted,
  });

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with TickerProviderStateMixin {
  bool _showOnboarding = false;
  int _currentStep = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: '¡Bienvenido a Notably!',
      description: 'Tu espacio personal para organizar ideas y tomar notas de manera profesional.',
      icon: Icons.note_alt_rounded,
      color: Colors.blue,
    ),
    OnboardingStep(
      title: 'Crea tus notas',
      description: 'Usa el botón + para crear una nueva nota. Puedes escribir con texto enriquecido.',
      icon: Icons.add_circle_outline,
      color: Colors.green,
    ),
    OnboardingStep(
      title: 'Busca rápidamente',
      description: 'Presiona Ctrl+K (Cmd+K en Mac) para buscar entre todas tus notas instantáneamente.',
      icon: Icons.search,
      color: Colors.orange,
    ),
    OnboardingStep(
      title: 'Modo oscuro',
      description: 'Cambia entre modo claro y oscuro desde la configuración para mayor comodidad.',
      icon: Icons.dark_mode,
      color: Colors.purple,
    ),
    OnboardingStep(
      title: '¡Comienza a crear!',
      description: 'Ya tienes todo listo. ¡Empieza a crear tus primeras notas y organiza tus ideas!',
      icon: Icons.rocket_launch,
      color: Colors.pink,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _checkShouldShowOnboarding();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkShouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!hasSeenOnboarding) {
      setState(() {
        _showOnboarding = true;
      });
      _fadeController.forward();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    _fadeController.reverse().then((_) {
      setState(() {
        _showOnboarding = false;
      });
      widget.onCompleted?.call();
    });
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showOnboarding)
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildOnboardingOverlay(),
          ),
      ],
    );
  }

  Widget _buildOnboardingOverlay() {
    final theme = Theme.of(context);
    final currentStep = _steps[_currentStep];

    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Saltar',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: currentStep.color.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: currentStep.color,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            currentStep.icon,
                            size: 60,
                            color: currentStep.color,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title
                        Text(
                          currentStep.title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          currentStep.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 48),

                        // Progress indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _steps.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: index == _currentStep ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: index == _currentStep
                                    ? currentStep.color
                                    : Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Navigation buttons
                        Row(
                          children: [
                            if (_currentStep > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _previousStep,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text('Anterior'),
                                ),
                              ),

                            if (_currentStep > 0) const SizedBox(width: 16),

                            Expanded(
                              child: ElevatedButton(
                                onPressed: _nextStep,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: currentStep.color,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  _currentStep == _steps.length - 1
                                      ? '¡Empezar!'
                                      : 'Siguiente',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}