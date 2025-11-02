import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_shopping_mate/data/models/shopping_list_model.dart';
import 'package:my_shopping_mate/data/repositories/shopping_list_repository.dart';

// --- BLoC Events ---
abstract class ShoppingListEvent extends Equatable {
  const ShoppingListEvent();
  @override
  List<Object> get props => [];
}

/// Event to load all shopping lists.
class ShoppingListsLoaded extends ShoppingListEvent {}

/// Event to create a new shopping list.
class ShoppingListCreated extends ShoppingListEvent {
  final String name;
  const ShoppingListCreated(this.name);
  @override
  List<Object> get props => [name];
}

// --- BLoC State ---
enum ShoppingListStatus { initial, loading, success, failure }

class ShoppingListState extends Equatable {
  final ShoppingListStatus status;
  final List<ShoppingList> shoppingLists;

  const ShoppingListState({
    this.status = ShoppingListStatus.initial,
    this.shoppingLists = const <ShoppingList>[],
  });

  ShoppingListState copyWith({
    ShoppingListStatus? status,
    List<ShoppingList>? shoppingLists,
  }) {
    return ShoppingListState(
      status: status ?? this.status,
      shoppingLists: shoppingLists ?? this.shoppingLists,
    );
  }

  @override
  List<Object> get props => [status, shoppingLists];
}

// --- The BLoC ---
class ShoppingListBloc extends Bloc<ShoppingListEvent, ShoppingListState> {
  final ShoppingListRepository _shoppingListRepository;

  ShoppingListBloc({required ShoppingListRepository shoppingListRepository})
      : _shoppingListRepository = shoppingListRepository,
        super(const ShoppingListState()) {
    on<ShoppingListsLoaded>(_onShoppingListsLoaded);
    on<ShoppingListCreated>(_onShoppingListCreated);
  }

  Future<void> _onShoppingListsLoaded(
      ShoppingListsLoaded event, Emitter<ShoppingListState> emit) async {
    emit(state.copyWith(status: ShoppingListStatus.loading));
    try {
      final lists = await _shoppingListRepository.getShoppingLists();
      emit(state.copyWith(status: ShoppingListStatus.success, shoppingLists: lists));
    } catch (_) {
      emit(state.copyWith(status: ShoppingListStatus.failure));
    }
  }

  Future<void> _onShoppingListCreated(
      ShoppingListCreated event, Emitter<ShoppingListState> emit) async {
    try {
      final newList = await _shoppingListRepository.createShoppingList(event.name);
      // Add the new list to the beginning of the current list.
      final updatedLists = [newList, ...state.shoppingLists];
      emit(state.copyWith(status: ShoppingListStatus.success, shoppingLists: updatedLists));
    } catch (_) {
      // If creation fails, we can emit a failure state or just revert.
      // For simplicity, we just ensure the status is back to success.
      emit(state.copyWith(status: ShoppingListStatus.success));
    }
  }
}