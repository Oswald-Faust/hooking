import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hookup4u2/models/user_model.dart';

// Events
abstract class MatchSuggestionsEvent {}

class LoadMatchSuggestions extends MatchSuggestionsEvent {
  final UserModel currentUser;
  LoadMatchSuggestions(this.currentUser);
}

class LikeUser extends MatchSuggestionsEvent {
  final UserModel currentUser;
  final UserModel likedUser;
  LikeUser(this.currentUser, this.likedUser);
}

class DislikeUser extends MatchSuggestionsEvent {
  final UserModel currentUser;
  final UserModel dislikedUser;
  DislikeUser(this.currentUser, this.dislikedUser);
}

class UndoLastAction extends MatchSuggestionsEvent {
  final UserModel currentUser;
  UndoLastAction(this.currentUser);
}

// States
abstract class MatchSuggestionsState {}

class MatchSuggestionsInitial extends MatchSuggestionsState {}

class MatchSuggestionsLoading extends MatchSuggestionsState {}

class MatchSuggestionsLoaded extends MatchSuggestionsState {
  final List<UserModel> suggestions;
  final List<UserModel> recentlyLiked;
  final List<UserModel> recentlyDisliked;

  MatchSuggestionsLoaded({
    required this.suggestions,
    this.recentlyLiked = const [],
    this.recentlyDisliked = const [],
  });
}

class MatchSuggestionsError extends MatchSuggestionsState {
  final String message;
  MatchSuggestionsError(this.message);
}

class MatchCreated extends MatchSuggestionsState {
  final UserModel matchedUser;
  MatchCreated(this.matchedUser);
}

// Bloc
class MatchSuggestionsBloc extends Bloc<MatchSuggestionsEvent, MatchSuggestionsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<UserModel> _recentlyLiked = [];
  List<UserModel> _recentlyDisliked = [];

  MatchSuggestionsBloc() : super(MatchSuggestionsInitial()) {
    on<LoadMatchSuggestions>(_onLoadMatchSuggestions);
    on<LikeUser>(_onLikeUser);
    on<DislikeUser>(_onDislikeUser);
    on<UndoLastAction>(_onUndoLastAction);
  }

  Future<void> _onLoadMatchSuggestions(
    LoadMatchSuggestions event,
    Emitter<MatchSuggestionsState> emit,
  ) async {
    try {
      emit(MatchSuggestionsLoading());

      // Récupérer les utilisateurs déjà vus
      final seenUsers = await _getSeenUsers(event.currentUser.id!);

      // Récupérer les suggestions
      final querySnapshot = await _firestore
          .collection('Users')
          .where('gender', whereIn: event.currentUser.lookingFor)
          .get();

      final suggestions = querySnapshot.docs
          .map((doc) => UserModel.fromDocument(doc))
          .where((user) => 
              user.id != event.currentUser.id && 
              !seenUsers.contains(user.id))
          .toList();

      emit(MatchSuggestionsLoaded(
        suggestions: suggestions,
        recentlyLiked: _recentlyLiked,
        recentlyDisliked: _recentlyDisliked,
      ));
    } catch (e) {
      emit(MatchSuggestionsError(e.toString()));
    }
  }

  Future<void> _onLikeUser(
    LikeUser event,
    Emitter<MatchSuggestionsState> emit,
  ) async {
    try {
      // Ajouter à la liste des likes
      await _firestore
          .collection('Users')
          .doc(event.currentUser.id)
          .collection('Likes')
          .doc(event.likedUser.id)
          .set({
        'userId': event.likedUser.id,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Vérifier si c'est un match
      final isMatch = await _checkForMatch(event.currentUser.id!, event.likedUser.id!);

      if (isMatch) {
        // Créer le match
        await _createMatch(event.currentUser, event.likedUser);
        emit(MatchCreated(event.likedUser));
      }

      // Mettre à jour l'état
      _recentlyLiked.add(event.likedUser);
      if (state is MatchSuggestionsLoaded) {
        final currentState = state as MatchSuggestionsLoaded;
        emit(MatchSuggestionsLoaded(
          suggestions: currentState.suggestions..remove(event.likedUser),
          recentlyLiked: _recentlyLiked,
          recentlyDisliked: _recentlyDisliked,
        ));
      }
    } catch (e) {
      emit(MatchSuggestionsError(e.toString()));
    }
  }

  Future<void> _onDislikeUser(
    DislikeUser event,
    Emitter<MatchSuggestionsState> emit,
  ) async {
    try {
      // Ajouter à la liste des dislikes
      await _firestore
          .collection('Users')
          .doc(event.currentUser.id)
          .collection('Dislikes')
          .doc(event.dislikedUser.id)
          .set({
        'userId': event.dislikedUser.id,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Mettre à jour l'état
      _recentlyDisliked.add(event.dislikedUser);
      if (state is MatchSuggestionsLoaded) {
        final currentState = state as MatchSuggestionsLoaded;
        emit(MatchSuggestionsLoaded(
          suggestions: currentState.suggestions..remove(event.dislikedUser),
          recentlyLiked: _recentlyLiked,
          recentlyDisliked: _recentlyDisliked,
        ));
      }
    } catch (e) {
      emit(MatchSuggestionsError(e.toString()));
    }
  }

  Future<void> _onUndoLastAction(
    UndoLastAction event,
    Emitter<MatchSuggestionsState> emit,
  ) async {
    try {
      UserModel? userToRestore;

      // Vérifier la dernière action
      if (_recentlyLiked.isNotEmpty) {
        userToRestore = _recentlyLiked.removeLast();
        await _firestore
            .collection('Users')
            .doc(event.currentUser.id)
            .collection('Likes')
            .doc(userToRestore.id)
            .delete();
      } else if (_recentlyDisliked.isNotEmpty) {
        userToRestore = _recentlyDisliked.removeLast();
        await _firestore
            .collection('Users')
            .doc(event.currentUser.id)
            .collection('Dislikes')
            .doc(userToRestore.id)
            .delete();
      }

      if (userToRestore != null && state is MatchSuggestionsLoaded) {
        final currentState = state as MatchSuggestionsLoaded;
        emit(MatchSuggestionsLoaded(
          suggestions: [userToRestore, ...currentState.suggestions],
          recentlyLiked: _recentlyLiked,
          recentlyDisliked: _recentlyDisliked,
        ));
      }
    } catch (e) {
      emit(MatchSuggestionsError(e.toString()));
    }
  }

  Future<List<String>> _getSeenUsers(String userId) async {
    final likes = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Likes')
        .get();

    final dislikes = await _firestore
        .collection('Users')
        .doc(userId)
        .collection('Dislikes')
        .get();

    return [
      ...likes.docs.map((doc) => doc.id),
      ...dislikes.docs.map((doc) => doc.id),
    ];
  }

  Future<bool> _checkForMatch(String userId1, String userId2) async {
    final otherUserLikes = await _firestore
        .collection('Users')
        .doc(userId2)
        .collection('Likes')
        .doc(userId1)
        .get();

    return otherUserLikes.exists;
  }

  Future<void> _createMatch(UserModel user1, UserModel user2) async {
    final matchData = {
      'timestamp': FieldValue.serverTimestamp(),
      'users': [user1.id, user2.id],
    };

    // Créer le match pour les deux utilisateurs
    await _firestore
        .collection('Matches')
        .doc('${user1.id}_${user2.id}')
        .set(matchData);

    // Notifications pour les deux utilisateurs
    await _firestore
        .collection('Users')
        .doc(user1.id)
        .collection('Notifications')
        .add({
      'type': 'match',
      'matchedUserId': user2.id,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });

    await _firestore
        .collection('Users')
        .doc(user2.id)
        .collection('Notifications')
        .add({
      'type': 'match',
      'matchedUserId': user1.id,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }
} 