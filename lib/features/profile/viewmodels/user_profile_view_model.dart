import 'package:biteq/features/profile/entities/profile_user.dart';
import 'package:biteq/features/profile/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provides the UserProfileViewModel
final userProfileViewModelProvider =
    StateNotifierProvider<UserProfileViewModel, AsyncValue<ProfileUser>>((ref) {
      // Use ProfileUser here
      return UserProfileViewModel(ref.read(userRepositoryProvider));
    });

// Provides the UserRepository instance
final userRepositoryProvider = Provider((ref) => UserRepository());

class UserProfileViewModel extends StateNotifier<AsyncValue<ProfileUser>> {
  // Use ProfileUser here
  final UserRepository _userRepository;

  UserProfileViewModel(this._userRepository)
    : super(const AsyncValue.loading()) {
    _loadUserProfile();
  }

  // Loads the user profile data
  Future<void> _loadUserProfile() async {
    try {
      state = const AsyncValue.loading();
      final user = await _userRepository.fetchUserProfile();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Allows manual refresh of the user profile
  Future<void> refreshUserProfile() async {
    await _loadUserProfile();
  }
}
