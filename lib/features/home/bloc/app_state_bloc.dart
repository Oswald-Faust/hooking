import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hookup4u2/models/user_model.dart';

// Events
abstract class AppStateEvent {}

class InitializeAppEvent extends AppStateEvent {}
class UpdateUserEvent extends AppStateEvent {
  final UserModel user;
  UpdateUserEvent(this.user);
}
class UpdatePurchaseStatusEvent extends AppStateEvent {
  final bool isPurchased;
  UpdatePurchaseStatusEvent(this.isPurchased);
}

// States
class AppState {
  final bool isInitialized;
  final bool isPurchased;
  final UserModel? currentUser;
  final bool isLoading;

  AppState({
    this.isInitialized = false,
    this.isPurchased = false,
    this.currentUser,
    this.isLoading = false,
  });

  AppState copyWith({
    bool? isInitialized,
    bool? isPurchased,
    UserModel? currentUser,
    bool? isLoading,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      isPurchased: isPurchased ?? this.isPurchased,
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Bloc
class AppStateBloc extends Bloc<AppStateEvent, AppState> {
  AppStateBloc() : super(AppState()) {
    on<InitializeAppEvent>(_onInitializeApp);
    on<UpdateUserEvent>(_onUpdateUser);
    on<UpdatePurchaseStatusEvent>(_onUpdatePurchaseStatus);
  }

  Future<void> _onInitializeApp(
    InitializeAppEvent event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      // Initialiser les services nécessaires
      emit(state.copyWith(
        isInitialized: true,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onUpdateUser(
    UpdateUserEvent event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(currentUser: event.user));
  }

  void _onUpdatePurchaseStatus(
    UpdatePurchaseStatusEvent event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(isPurchased: event.isPurchased));
  }
} 