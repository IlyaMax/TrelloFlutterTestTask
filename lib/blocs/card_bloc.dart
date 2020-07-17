import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trellotesttask/events/card_event.dart';
import 'package:http/http.dart' as http;
import 'package:trellotesttask/models/card.dart';
import 'package:trellotesttask/utils/failure.dart';
import 'package:trellotesttask/utils/token_storage.dart';

class CardBloc {
  final _cardListStateController = StreamController<AsyncSnapshot<List<BoardCard>>>();

  StreamSink<AsyncSnapshot<List<BoardCard>>> get _cardListStateSink => _cardListStateController.sink;

  Stream<AsyncSnapshot<List<BoardCard>>> get cardListStateStream => _cardListStateController.stream;

  final _cardEventController = StreamController<CardEvent>();

  Sink<CardEvent> get cardEventSink => _cardEventController.sink;

  CardBloc() {
    _cardListStateSink.addStream(fetchCardList());
    _cardEventController.stream.listen(_mapEventToState);
  }

  Stream<AsyncSnapshot<List<BoardCard>>> fetchCardList() async* {
    yield AsyncSnapshot.withData(ConnectionState.waiting, null);
    try {
      final token = await TokenStorage.obtainRefreshedToken();
      final response = await http.get("https://trello.backend.tests.nekidaem.ru/api/v1/cards", headers: {"Authorization": "JWT $token"});
      print("STATUS code of fetching card list: ${response.statusCode}");
      if (response.statusCode == 200) {
        Iterable cardList = json.decode(utf8.decode(response.bodyBytes));
        yield AsyncSnapshot.withData(ConnectionState.done, cardList.map((cardMap) => BoardCard.fromMap(cardMap)).toList());
      } else if (response.statusCode == 401) {
        yield AsyncSnapshot.withError(ConnectionState.done, TokenExpiredFailure());
      }
    } on SocketException {
      yield AsyncSnapshot.withError(ConnectionState.done, ConnectionFailure());
    } on TokenExpiredFailure {
      yield AsyncSnapshot.withError(ConnectionState.done, TokenExpiredFailure());
    } catch (e) {
      yield AsyncSnapshot.withError(ConnectionState.done, UserFailure("Failed to fetch cards from server"));
    }
  }

  void _mapEventToState(CardEvent event) {
    if (event is FetchCardsEvent) {
      _cardListStateSink.addStream(fetchCardList());
    }
  }

  void dispose() {
    _cardEventController.close();
    _cardListStateController.close();
  }
}
