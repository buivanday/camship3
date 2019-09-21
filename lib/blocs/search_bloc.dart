import 'dart:async';

import 'shop_api.dart';
import 'search_state.dart';
import 'package:rxdart/rxdart.dart';

class SearchBloc {
  final Sink<String> onTextChanged;
  final Stream<SearchState> state;

  factory SearchBloc(ShopApi api) {
    final onTextChanged = PublishSubject<String>();
    final state = onTextChanged
        .distinct()
        .debounceTime(const Duration(milliseconds: 250))
        .switchMap<SearchState>((String term) => _search(term, api))
        .startWith(SearchAll());
    return SearchBloc._(onTextChanged, state);
  }

  SearchBloc._(this.onTextChanged, this.state);

  void dispose() {
    onTextChanged.close();
  }

  static Stream<SearchState> _search(String term, ShopApi api) async* {
    yield SearchLoading();

    try {
      final result = await api.search(term);
      if (result.isEmpty) {
        yield SearchEmpty();
      } else {
        yield SearchPopulated(result);
      }
    } catch (e) {
      yield SearchError();
    }
  }
}