abstract class OnboardingEvent {}

class CreateAccountWithEmail extends OnboardingEvent {
  final String email;
  final String password;
  CreateAccountWithEmail({required this.email, required this.password});
}

class StartPhoneVerification extends OnboardingEvent {
  final String phoneNumber;
  StartPhoneVerification({required this.phoneNumber});
}

class PhoneVerificationCodeSent extends OnboardingEvent {
  final String verificationId;
  PhoneVerificationCodeSent(this.verificationId);
}

class VerifyPhoneNumber extends OnboardingEvent {
  final String smsCode;
  VerifyPhoneNumber({required this.smsCode});
}

class OnboardingError extends OnboardingEvent {
  final String error;
  OnboardingError(this.error);
}

class UpdateFirstName extends OnboardingEvent {
  final String firstName;
  UpdateFirstName(this.firstName);
}

class UpdatePassions extends OnboardingEvent {
  final List<String> passions;
  UpdatePassions(this.passions);
}

class UpdateBirthDate extends OnboardingEvent {
  final DateTime birthDate;
  UpdateBirthDate(this.birthDate);
}

class UpdateGender extends OnboardingEvent {
  final String gender;
  UpdateGender(this.gender);
}

class UpdateLookingFor extends OnboardingEvent {
  final List<String> lookingFor;
  UpdateLookingFor(this.lookingFor);
}

class UpdatePhotos extends OnboardingEvent {
  final List<String> photos;
  UpdatePhotos(this.photos);
}

class UpdateBio extends OnboardingEvent {
  final String bio;
  UpdateBio(this.bio);
}

class CompleteOnboarding extends OnboardingEvent {} 