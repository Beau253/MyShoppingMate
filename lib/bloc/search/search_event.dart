import 'package:equatable/equatable.dart';
abstract class SearchEvent extends Equatable {
const SearchEvent();
@override
List<Object> get props => [];
}
/// Event triggered when the search query is changed by the user.
class SearchQueryChanged extends SearchEvent {
final String query;
const SearchQueryChanged(this.query);
@override
List<Object> get props => [query];
