import 'package:othtix_app/src/data/models/event/event_model.dart';
import 'package:othtix_app/src/data/models/event/event_query.dart';
import 'package:othtix_app/src/data/repositories/event_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_search_cubit.freezed.dart';
part 'event_search_state.dart';

class EventSearchCubit extends Cubit<EventSearchState> {
  final EventRepository _eventRepository;

  EventSearchCubit(this._eventRepository)
      : super(const EventSearchState.initial());

  Future<void> getEvents(EventQuery query) async {
    final (previousEvents) = state.maybeMap(
      loaded: (state) => (state.events),
      orElse: () => (<EventModel>[]),
    );

    emit(const EventSearchState.loading());

    final result = await _eventRepository.getPublishedEvents(query);

    return result.fold(
      (e) {
        return emit(EventSearchState.loaded(
          previousEvents,
          exception: e,
          query: query,
        ));
      },
      (events) {
        return emit(EventSearchState.loaded(
          events,
          query: query,
        ));
      },
    );
  }

  Future<void> getMoreEvents() async {
    if (state is! _Loaded) return;

    final (previousEvents, query, hasReachedMax) = state.maybeMap(
      loaded: (state) => (
        state.events,
        state.query,
        state.hasReachedMax,
      ),
      orElse: () => (<EventModel>[], null, false),
    );

    if (query == null) return;

    final newQueries = query.copyWith(
      page: hasReachedMax ? query.page : query.page + 1,
    );

    final result = await _eventRepository.getPublishedEvents(newQueries);

    return result.fold(
      (e) {
        return emit(EventSearchState.loaded(
          previousEvents,
          exception: e,
          query: newQueries,
          hasReachedMax: true,
        ));
      },
      (events) {
        return emit(EventSearchState.loaded(
          [...previousEvents, ...events],
          query: newQueries,
          hasReachedMax: events.isEmpty,
        ));
      },
    );
  }
}
