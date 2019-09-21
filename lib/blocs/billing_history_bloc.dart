import 'dart:async';

import 'billing_history_api.dart';
import 'search_state.dart';
import 'package:rxdart/rxdart.dart';

class BillingHistoryBloc {
  final Sink<String> onDateChanged;
  final Stream<SearchState> state;

  factory BillingHistoryBloc(BillingHistoryApi api) {
    final onDateChanged = PublishSubject<String>();
    final state = onDateChanged
        .distinct()
        .debounceTime(const Duration(milliseconds: 250))
        .switchMap<SearchState>((String dateRange) => _search(dateRange, api))
        .startWith(SearchAll());
    return BillingHistoryBloc._(onDateChanged, state);
  }

  BillingHistoryBloc._(this.onDateChanged, this.state);

  void dispose() {
    onDateChanged.close();
  }

  static Stream<SearchState> _search(String dateRange, BillingHistoryApi api) async* {
    yield SearchLoading();

    try {
      String start = dateRange.split('_')[0];
      String end = dateRange.split('_')[1];
      final result = await api.search(start, end);
      if (result.isEmpty) {
        yield SearchEmpty();
      } else {
        yield SearchBillingPopulated(result);
      }
    } catch (e) {
      print(e);
      yield SearchError();
    }
  }
}