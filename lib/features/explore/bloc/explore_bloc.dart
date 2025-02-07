import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hookup4u2/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Events
abstract class ExploreEvent {}

class LoadNearbyUsers extends ExploreEvent {
  final UserModel currentUser;
  final double maxDistance;

  LoadNearbyUsers({
    required this.currentUser,
    this.maxDistance = 100,
  });
}

class UpdateUserLocation extends ExploreEvent {
  final UserModel user;
  final GeoPoint location;

  UpdateUserLocation({
    required this.user,
    required this.location,
  });
}

// States
abstract class ExploreState {}

class ExploreInitial extends ExploreState {}

class ExploreLoading extends ExploreState {}

class ExploreLoaded extends ExploreState {
  final List<UserModel> nearbyUsers;
  final Map<String, double> distances;

  ExploreLoaded({
    required this.nearbyUsers,
    required this.distances,
  });
}

class ExploreError extends ExploreState {
  final String message;

  ExploreError(this.message);
}

// Bloc
class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ExploreBloc() : super(ExploreInitial()) {
    on<LoadNearbyUsers>(_onLoadNearbyUsers);
    on<UpdateUserLocation>(_onUpdateUserLocation);
  }

  Future<void> _onLoadNearbyUsers(
    LoadNearbyUsers event,
    Emitter<ExploreState> emit,
  ) async {
    try {
      emit(ExploreLoading());

      // Récupérer les utilisateurs à proximité
      final userDocs = await _firestore
          .collection('Users')
          .where('gender', whereIn: event.currentUser.lookingFor)
          .get();

      final List<UserModel> nearbyUsers = [];
      final Map<String, double> distances = {};

      for (var doc in userDocs.docs) {
        if (doc.id != event.currentUser.id) {
          final user = UserModel.fromDocument(doc);
          
          // Calculer la distance
          final distance = _calculateDistance(
            event.currentUser.coordinates!['latitude'],
            event.currentUser.coordinates!['longitude'],
            user.coordinates!['latitude'],
            user.coordinates!['longitude'],
          );

          // Ajouter l'utilisateur s'il est dans le rayon
          if (distance <= event.maxDistance) {
            nearbyUsers.add(user);
            distances[user.id!] = distance;
          }
        }
      }

      emit(ExploreLoaded(
        nearbyUsers: nearbyUsers,
        distances: distances,
      ));
    } catch (e) {
      emit(ExploreError(e.toString()));
    }
  }

  Future<void> _onUpdateUserLocation(
    UpdateUserLocation event,
    Emitter<ExploreState> emit,
  ) async {
    try {
      await _firestore.collection('Users').doc(event.user.id).update({
        'coordinates': {
          'latitude': event.location.latitude,
          'longitude': event.location.longitude,
          'timestamp': FieldValue.serverTimestamp(),
        },
      });

      // Recharger les utilisateurs à proximité
      add(LoadNearbyUsers(currentUser: event.user));
    } catch (e) {
      emit(ExploreError(e.toString()));
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Rayon de la Terre en km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = (
      _sin(dLat / 2) * _sin(dLat / 2) +
      _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) *
      _sin(dLon / 2) * _sin(dLon / 2)
    );

    final double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (3.141592653589793 / 180);
  }

  double _sin(double x) {
    return double.parse(x.toString());
  }

  double _cos(double x) {
    return double.parse(x.toString());
  }

  double _sqrt(double x) {
    return double.parse(x.toString());
  }

  double _atan2(double y, double x) {
    return double.parse((y / x).toString());
  }
} 