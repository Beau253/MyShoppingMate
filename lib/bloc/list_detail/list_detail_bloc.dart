import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_shopping_mate/data/models/list_item_model.dart';
import 'package:my_shopping_mate/data/repositories/shopping_list_repository.dart';

// --- BLoC Events ---
abstract class ListDetailEvent extends Equatable {
  const ListDetailEvent();
  @override
  List<Object> get props => [];
}

/// Event to load the items for a specific list.
class ListDetailLoaded extends ListDetailEvent {
  final String listId;
  const ListDetailLoaded(this.listId);
  @override
  List<Object> get props => [listId];
}

/// Event to toggle the checked state of an item.
class ListItemToggled extends ListDetailEvent {
  final ListItem item;
  const ListItemToggled(this.item);
  @override
  List<Object> get props => [item];
}

/// --- NEW EVENT ---
/// Event to add a new item to the list.
class ListItemAdded extends ListDetailEvent {
  final String productName;
  final int quantity;
  final double price;

  const ListItemAdded({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  @override
  List<Object> get props => [productName, quantity, price];
}


// --- BLoC State (remains the same) ---
enum ListDetailStatus { initial, loading, success, failure }

class ListDetailState extends Equatable {
  final ListDetailStatus status;
  final List<ListItem> items;
  final String listId;

  const ListDetailState({
    this.status = ListDetailStatus.initial,
    this.items = const <ListItem>[],
    this.listId = '',
  });

  // A getter to calculate the total cost
  double get totalCost {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  ListDetailState copyWith({
    ListDetailStatus? status,
    List<ListItem>? items,
    String? listId,
  }) {
    return ListDetailState(
      status: status ?? this.status,
      items: items ?? this.items,
      listId: listId ?? this.listId,
    );
  }

  @override
  List<Object> get props => [status, items, listId];
}

// --- The BLoC ---
class ListDetailBloc extends Bloc<ListDetailEvent, ListDetailState> {
  final ShoppingListRepository _shoppingListRepository;

  ListDetailBloc({required ShoppingListRepository shoppingListRepository})
      : _shoppingListRepository = shoppingListRepository,
        super(const ListDetailState()) {
    on<ListDetailLoaded>(_onListDetailLoaded);
    on<ListItemToggled>(_onListItemToggled);
    on<ListItemAdded>(_onListItemAdded); // --- REGISTER NEW HANDLER ---
  }

  Future<void> _onListDetailLoaded(
      ListDetailLoaded event, Emitter<ListDetailState> emit) async {
    emit(state.copyWith(status: ListDetailStatus.loading, listId: event.listId));
    try {
      final items = await _shoppingListRepository.getListItems(event.listId);
      emit(state.copyWith(status: ListDetailStatus.success, items: items));
    } catch (_) {
      emit(state.copyWith(status: ListDetailStatus.failure));
    }
  }

  Future<void> _onListItemToggled(
      ListItemToggled event, Emitter<ListDetailState> emit) async {
    final updatedItem = event.item.copyWith(isChecked: !event.item.isChecked);
    final updatedList = state.items.map((item) {
      return item.id == updatedItem.id ? updatedItem : item;
    }).toList();
    emit(state.copyWith(items: updatedList));

    try {
      await _shoppingListRepository.updateListItem(state.listId, updatedItem);
    } catch (_) {
      emit(state.copyWith(items: state.items));
    }
  }

  // --- NEW HANDLER ---
  Future<void> _onListItemAdded(
      ListItemAdded event, Emitter<ListDetailState> emit) async {
    try {
      final newItem = await _shoppingListRepository.addListItem(
        listId: state.listId,
        productName: event.productName,
        quantity: event.quantity,
        price: event.price,
      );
      // Add the new item to the current list of items and emit success
      final updatedList = List<ListItem>.from(state.items)..add(newItem);
      emit(state.copyWith(status: ListDetailStatus.success, items: updatedList));
    } catch (_) {
      // In case of failure, we can emit an error state or just log it.
      // For now, we do nothing to revert the UI.
    }
  }
}