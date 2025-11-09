import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_shopping_mate/data/models/user_model.dart';
import 'package:my_shopping_mate/data/repositories/user_repository.dart';

// --- BLoC Events ---
// Events are the inputs to the BLoC.

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

/// Event to signal that the user's profile should be loaded.
class ProfileLoaded extends ProfileEvent {}

/// Event to signal that the user's name has been changed and should be saved.
class ProfileNameChanged extends ProfileEvent {
  final String name;
  const ProfileNameChanged(this.name);
  @override
  List<Object> get props => [name];
}

// --- BLoC State ---
// State is the output of the BLoC, which the UI reacts to.

enum ProfileStatus { initial, loading, success, failure, saving }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final User? user;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, user];
}

// --- The BLoC ---
// The BLoC contains the business logic, transforming events into states.

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;

  ProfileBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const ProfileState()) {
    on<ProfileLoaded>(_onProfileLoaded);
    on<ProfileNameChanged>(_onProfileNameChanged);
  }

  Future<void> _onProfileLoaded(
      ProfileLoaded event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final user = await _userRepository.getUser();
      emit(state.copyWith(status: ProfileStatus.success, user: user));
    } catch (_) {
      emit(state.copyWith(status: ProfileStatus.failure));
    }
  }

  Future<void> _onProfileNameChanged(
      ProfileNameChanged event, Emitter<ProfileState> emit) async {
    // Only proceed if there's a user to update.
    if (state.user == null) return;
    
    emit(state.copyWith(status: ProfileStatus.saving));
    try {
      await _userRepository.updateUser(name: event.name);
      // After saving, emit a new success state with the updated user data.
      // We can optimistically update the user object before re-fetching.
      final updatedUser = state.user!.copyWith(name: event.name);
      emit(state.copyWith(status: ProfileStatus.success, user: updatedUser,));
    } catch (_) {
      // If saving fails, revert to the previous successful state.
      // The user object is already correct from the previous success state.
      emit(state.copyWith(status: ProfileStatus.success));
    }
  }
}