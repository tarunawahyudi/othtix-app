import 'package:othtix_app/src/blocs/onboarding/onboarding_cubit.dart';
import 'package:othtix_app/src/config/routes/route_names.dart';
import 'package:othtix_app/src/presentations/extensions/extensions.dart';
import 'package:othtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();

  final _pageIndexListenable = ValueNotifier(0);

  @override
  void dispose() {
    _controller.dispose();
    _pageIndexListenable.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    const _OnboardingHero(
      imgAsset: 'assets/images/onboarding-step-1.png',
      text: 'Create & share your event',
    ),
    const _OnboardingHero(
      imgAsset: 'assets/images/onboarding-step-2.png',
      text: 'Find events and buy tickets. No hassle',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsivePadding(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              flex: 8,
              child: PageView(
                controller: _controller,
                onPageChanged: (value) {
                  _pageIndexListenable.value = value;
                },
                children: _pages,
              ),
            ),
            Expanded(
              flex: 2,
              child: _onboardingAction(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _onboardingAction(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 48, top: 8),
            child: SmoothPageIndicator(
              controller: _controller,
              count: _pages.length,
              effect: ExpandingDotsEffect(
                activeDotColor: context.colorScheme.primary,
                dotWidth: 8,
                dotHeight: 8,
              ),
              onDotClicked: (value) {
                _pageIndexListenable.value = value;
                _controller.animateToPage(
                  value,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ValueListenableBuilder(
              valueListenable: _pageIndexListenable,
              builder: (context, value, _) {
                if (value >= _pages.length - 1) {
                  return FilledButton(
                    onPressed: () {
                      context.read<OnboardingCubit>().finishOnboarding();

                      context.goNamed(RouteNames.login);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      child: Text('Get Started'),
                    ),
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<OnboardingCubit>().finishOnboarding();

                          context.goNamed(RouteNames.login);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('Skip'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          _pageIndexListenable.value += 1;
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 8),
                              Text('Next'),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios_outlined,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero({
    required this.imgAsset,
    required this.text,
  });

  final String imgAsset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Image.asset(imgAsset),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
