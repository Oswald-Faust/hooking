import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_event.dart';
import 'package:hookup4u2/features/auth/onboarding/bloc/onboarding_state.dart';
import 'package:hookup4u2/features/auth/services/onboarding_service.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingService _onboardingService;
  
  OnboardingBloc({required OnboardingService onboardingService})
      : _onboardingService = onboardingService,
        super(OnboardingState.initial()) {
    
    on<UpdateFirstName>((event, emit) async {
      emit(state.copyWith(firstName: event.firstName));
      await _onboardingService.updateUserProfile(
        field: 'name',
        value: event.firstName,
      );
    });

    on<UpdatePassions>((event, emit) async {
      emit(state.copyWith(passions: event.passions));
      await _onboardingService.updateUserProfile(
        field: 'passions',
        value: event.passions,
      );
    });

    on<UpdateBirthDate>((event, emit) async {
      emit(state.copyWith(birthDate: event.birthDate));
      await _onboardingService.updateUserProfile(
        field: 'birthDate',
        value: event.birthDate,
      );
    });

    on<UpdateGender>((event, emit) async {
      emit(state.copyWith(gender: event.gender));
      await _onboardingService.updateUserProfile(
        field: 'gender',
        value: event.gender,
      );
    });

    on<UpdateLookingFor>((event, emit) async {
      emit(state.copyWith(lookingFor: event.lookingFor));
      await _onboardingService.updateUserProfile(
        field: 'lookingFor',
        value: event.lookingFor,
      );
    });

    on<UpdatePhotos>((event, emit) async {
      emit(state.copyWith(photos: event.photos));
      await _onboardingService.updateUserProfile(
        field: 'photos',
        value: event.photos,
      );
    });

    on<UpdateBio>((event, emit) async {
      emit(state.copyWith(bio: event.bio));
      await _onboardingService.updateUserProfile(
        field: 'bio',
        value: event.bio,
      );
    });

    // Gestion de la création du compte par email
    on<CreateAccountWithEmail>((event, emit) async {
      try {
        emit(state.copyWith(status: OnboardingStatus.loading));
        
        final userCredential = await _onboardingService.createAccountWithEmail(
          email: event.email,
          password: event.password,
        );

        emit(state.copyWith(
          status: OnboardingStatus.accountCreated,
          email: event.email,
        ));
      } catch (error) {
        emit(state.copyWith(
          status: OnboardingStatus.failure,
          error: error.toString(),
        ));
      }
    });

    // Gestion de la création du compte par téléphone
    on<StartPhoneVerification>((event, emit) async {
      try {
        emit(state.copyWith(status: OnboardingStatus.loading));
        
        await _onboardingService.startPhoneVerification(
          phoneNumber: event.phoneNumber,
          onCodeSent: (verificationId) {
            add(PhoneVerificationCodeSent(verificationId));
          },
          onError: (error) {
            add(OnboardingError(error));
          },
        );

        emit(state.copyWith(phoneNumber: event.phoneNumber));
      } catch (error) {
        emit(state.copyWith(
          status: OnboardingStatus.failure,
          error: error.toString(),
        ));
      }
    });

    // Gestion du code OTP reçu
    on<PhoneVerificationCodeSent>((event, emit) {
      emit(state.copyWith(
        status: OnboardingStatus.awaitingOTP,
        verificationId: event.verificationId,
      ));
    });

    // Vérification du code OTP
    on<VerifyPhoneNumber>((event, emit) async {
      try {
        emit(state.copyWith(status: OnboardingStatus.loading));
        
        await _onboardingService.verifyPhoneNumber(
          verificationId: state.verificationId!,
          smsCode: event.smsCode,
        );

        emit(state.copyWith(status: OnboardingStatus.accountCreated));
      } catch (error) {
        emit(state.copyWith(
          status: OnboardingStatus.failure,
          error: error.toString(),
        ));
      }
    });

    // Finalisation de l'onboarding
    on<CompleteOnboarding>((event, emit) async {
      try {
        emit(state.copyWith(status: OnboardingStatus.loading));
        
        if (!_isOnboardingDataComplete(state)) {
          throw Exception('Toutes les informations requises ne sont pas remplies');
        }

        final user = await _onboardingService.completeOnboarding(
          firstName: state.firstName!,
          birthDate: state.birthDate!,
          gender: state.gender!,
          lookingFor: state.lookingFor!,
          passions: state.passions!,
          photos: state.photos!,
          bio: state.bio!,
        );

        emit(state.copyWith(
          status: OnboardingStatus.success,
          user: user,
        ));
      } catch (error) {
        emit(state.copyWith(
          status: OnboardingStatus.failure,
          error: error.toString(),
        ));
      }
    });
  }

  bool _isOnboardingDataComplete(OnboardingState state) {
    return state.firstName != null &&
        state.birthDate != null &&
        state.gender != null &&
        state.lookingFor != null &&
        state.passions != null &&
        state.photos != null &&
        state.bio != null &&
        state.photos!.isNotEmpty &&
        state.passions!.isNotEmpty &&
        state.lookingFor!.isNotEmpty;
  }
} 