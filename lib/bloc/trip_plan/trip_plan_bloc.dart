import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_shopping_mate/data/models/trip_plan_model.dart';
import 'package:my_shopping_mate/data/repositories/trip_plan_repository.dart';

// --- BLoC Events ---
abstract class TripPlanEvent extends Equatable {
  const TripPlanEvent();
  @override
  List<Object> get props => [];
}

/// Event to load the optimized trip plan for a list.
class TripPlanLoaded extends TripPlanEvent {
  final String listId;
  const TripPlanLoaded(this.listId);
  @override
  List<Object> get props => [listId];
}

/// Event to move an item from one store to another.
class TripItemMoved extends TripPlanEvent {
  final TripItem itemToMove;
  const TripItemMoved(this.itemToMove);
  @override
  List<Object> get props => [itemToMove];
}

// --- BLoC State ---
enum TripPlanStatus { initial, loading, success, failure }

class TripPlanState extends Equatable {
  final TripPlanStatus status;
  final TripPlan? tripPlan;

  const TripPlanState({
    this.status = TripPlanStatus.initial,
    this.tripPlan,
  });

  TripPlanState copyWith({
    TripPlanStatus? status,
    TripPlan? tripPlan,
  }) {
    return TripPlanState(
      status: status ?? this.status,
      tripPlan: tripPlan ?? this.tripPlan,
    );
  }

  @override
  List<Object?> get props => [status, tripPlan];
}

// --- The BLoC ---
class TripPlanBloc extends Bloc<TripPlanEvent, TripPlanState> {
  final TripPlanRepository _tripPlanRepository;

  TripPlanBloc({required TripPlanRepository tripPlanRepository})
      : _tripPlanRepository = tripPlanRepository,
        super(const TripPlanState()) {
    on<TripPlanLoaded>(_onTripPlanLoaded);
    on<TripItemMoved>(_onTripItemMoved);
  }

  Future<void> _onTripPlanLoaded(
      TripPlanLoaded event, Emitter<TripPlanState> emit) async {
    emit(state.copyWith(status: TripPlanStatus.loading));
    try {
      final plan = await _tripPlanRepository.getTripPlan(event.listId);
      emit(state.copyWith(status: TripPlanStatus.success, tripPlan: plan));
    } catch (_) {
      emit(state.copyWith(status: TripPlanStatus.failure));
    }
  }

  void _onTripItemMoved(
      TripItemMoved event, Emitter<TripPlanState> emit) {
    if (state.tripPlan == null) return;

    final currentPlan = state.tripPlan!;
    final itemToMove = event.itemToMove;
    final fromStoreId = itemToMove.currentStoreId;
    final toStoreId = itemToMove.alternativeStoreId;

    // Create a deep copy of the stores to modify
    final newStores = currentPlan.stores.map((store) {
      return TripStore(
          storeId: store.storeId,
          storeName: store.storeName,
          items: List<TripItem>.from(store.items));
    }).toList();

    final sourceStore = newStores.firstWhere((s) => s.storeId == fromStoreId);
    final destStore = newStores.firstWhere((s) => s.storeId == toStoreId);

    // Create the new item with swapped store IDs and prices
    final movedItem = TripItem(
      item: itemToMove.item.copyWith(), // Create a copy of the list item
      currentStoreId: toStoreId,
      alternativeStoreId: fromStoreId,
      alternativePrice: itemToMove.item.price, // Old price is now the alternative
    );

    // Remove from source and add to destination
    sourceStore.items.removeWhere((item) => item.item.id == itemToMove.item.id);
    destStore.items.add(movedItem);

    final newPlan = TripPlan(stores: newStores);
    emit(state.copyWith(tripPlan: newPlan));
  }
}