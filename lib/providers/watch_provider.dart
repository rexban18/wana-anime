import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/episode_model.dart';

class WatchState {
  final EpisodeModel? episode;
  final int selectedServerIndex;
  final bool isLoading;
  final String? error;

  const WatchState({
    this.episode,
    this.selectedServerIndex = 0,
    this.isLoading = false,
    this.error,
  });

  WatchState copyWith({
    EpisodeModel? episode,
    int? selectedServerIndex,
    bool? isLoading,
    String? error,
  }) {
    return WatchState(
      episode: episode ?? this.episode,
      selectedServerIndex: selectedServerIndex ?? this.selectedServerIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  String? get currentServerUrl {
    if (episode == null) return null;
    if (episode!.servers.isEmpty) return null;
    if (selectedServerIndex >= episode!.servers.length) return null;
    return episode!.servers[selectedServerIndex];
  }
}

final watchProvider = StateNotifierProvider<WatchNotifier, WatchState>((ref) {
  return WatchNotifier(ref);
});

class WatchNotifier extends StateNotifier<WatchState> {
  final Ref _ref;

  WatchNotifier(this._ref) : super(const WatchState());

  void setEpisode(EpisodeModel episode) {
    state = WatchState(episode: episode, selectedServerIndex: 0);
  }

  void switchServer(int index) {
    if (state.episode == null) return;
    if (index >= state.episode!.servers.length) return;
    state = state.copyWith(selectedServerIndex: index, error: null);
  }

  void markError() {
    state = state.copyWith(error: 'Server failed');
  }

  void retry() {
    state = state.copyWith(error: null);
  }

  void tryNextServer() {
    if (state.episode == null) return;
    final nextIndex = state.selectedServerIndex + 1;
    if (nextIndex < state.episode!.servers.length) {
      switchServer(nextIndex);
    } else {
      state = state.copyWith(error: 'No more servers available');
    }
  }
}
