String? workProofRedirect({
  required bool isLoading,
  required bool hasError,
  required bool onboardingCompleted,
  required String location,
}) {
  const startup = '/startup';
  const onboarding = '/onboarding';
  const home = '/home';

  if (isLoading || hasError) return location == startup ? null : startup;
  if (!onboardingCompleted) {
    return location == onboarding ? null : onboarding;
  }
  if (location == startup || location == onboarding) return home;
  return null;
}
