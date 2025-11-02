import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_shopping_mate/data/models/store_model.dart';
import 'package:my_shopping_mate/data/repositories/store_repository.dart';

// --- BLoC Events ---
abstract class MyStoresEvent extends Equatable {
  const MyStoresEvent();
  @override
  List<Object> get props => [];
}

/// Event to load the user's stores.
class MyStoresLoaded extends MyStoresEvent {}

/// Event to remove a store from the user's list.
class MyStoreRemoved extends MyStoresEvent {
  final Store store;
  const MyStoreRemoved(this.store);
  @override
  List<Object> get props => [store];
}

/// Event to reorder the user's list of stores.
class MyStoresReordered extends MyStoresEvent {
  final int oldIndex;
  final int newIndex;
  const MyStoresReordered(this.oldIndex, this.newIndex);
  @override
  List<Object> get props => [oldIndex, newIndex];
}

// --- BLoC State ---
enum MyStoresStatus { initial, loading, success, failure }

class MyStoresState extends Equatable {
  final MyStoresStatus status;
  final List<Store> stores;

  const MyStoresState({
    this.status = MyStoresStatus.initial,
    this.stores = const <Store>[],
  });

  MyStoresState copyWith({
    MyStoresStatus? status,
    List<Store>? stores,
  }) {
    return MyStoresState(
      status: status ?? this.status,
      stores: stores ?? this.stores,
    );
  }

  @override
  List<Object> get props => [status, stores];
}

// --- The BLoC ---
class MyStoresBloc extends Bloc<MyStoresEvent, MyStoresState> {
  final StoreRepository _storeRepository;

  MyStoresBloc({required StoreRepository storeRepository})
      : _storeRepository = storeRepository,
        super(const MyStoresState()) {
    on<MyStoresLoaded>(_onMyStoresLoaded);
    on<MyStoreRemoved>(_onMyStoreRemoved);
    on<MyStoresReordered>(_onMyStoresReordered);
  }

  Future<void> _onMyStoresLoaded(
      MyStoresLoaded event, Emitter<MyStoresState> emit) async {
    emit(state.copyWith(status: MyStoresStatus.loading));
    try {
      final stores = await _storeRepository.getMyStores();
      emit(state.copyWith(status: MyStoresStatus.success, stores: stores));
    } catch (_) {
      emit(state.copyWith(status: MyStoresStatus.failure));
    }
  }

  Future<void> _onMyStoreRemoved(
      MyStoreRemoved event, Emitter<MyStoresState> emit) async {
    // Optimistically update the UI
    final updatedList = List<Store>.from(state.stores)..remove(event.store);
    emit(state.copyWith(stores: updatedList));

    try {
      await _storeRepository.removeStore(event.store.id);
    } catch (_) {
      // If the API call fails, revert the state
      emit(state.copyWith(stores: state.stores));
    }
  }

  void _onMyStoresReordered(
      MyStoresReordered event, Emitter<MyStoresState> emit) async {
    final int oldIndex = event.oldIndex;
    int newIndex = event.newIndex;
    
    // This logic is specific to ReorderableListView
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final updatedList = List<Store>.from(state.stores);
    final store = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, store);
    
    emit(state.copyWith(stores: updatedList));
    
    try {
      await _storeRepository.reorderStores(updatedList);
    } catch (_) {
      // Revert on failure
      emit(state.copyWith(stores: state.stores));
    }
  }
}