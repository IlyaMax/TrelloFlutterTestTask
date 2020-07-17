import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trellotesttask/blocs/card_bloc.dart';
import 'package:trellotesttask/events/card_event.dart';
import 'package:trellotesttask/models/card.dart';
import 'package:trellotesttask/utils/failure.dart';
import 'package:trellotesttask/utils/shared_preferences.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  CardBloc _cardBloc;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: StreamProvider<AsyncSnapshot<List<BoardCard>>>(
        create: (context) => _cardBloc.cardListStateStream,
        child: Consumer<AsyncSnapshot<List<BoardCard>>>(
          builder: (context, snapshot, child) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              final groupsList = List<List<BoardCard>>.generate(BoardCard.groupNames.length, (_) => List());
              snapshot.data.forEach((boardCard) {
                groupsList[boardCard.groupIndex].add(boardCard);
              });
              return PageView.builder(
                itemCount: 4,
                itemBuilder: (context, groupIndex) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    color: theme.primaryColor,
                    child: SafeArea(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                BoardCard.groupNames[groupIndex],
                                style: theme.textTheme.headline4,
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                physics: BouncingScrollPhysics(),
                                itemCount: groupsList[groupIndex].length,
                                shrinkWrap: true,
                                itemBuilder: (context, cardIndex) {
                                  return Container(
                                    margin: EdgeInsets.all(8),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(groupsList[groupIndex][cardIndex].text),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.error is TokenExpiredFailure) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("Please log in again"),
                  duration: Duration(seconds: 1),
                  backgroundColor: theme.primaryColorDark,
                ));
                final sPref = SharedPreferencesData();
                sPref.setAppStatusInfo(AppStatus.INIT);
                Navigator.pushReplacementNamed(context, "/login");
              });
              return SizedBox.shrink();
            } else {
              print(snapshot.error.toString());
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(snapshot.error.toString()),
                  duration: Duration(seconds: 1),
                  backgroundColor: theme.primaryColorDark,
                ));
              });
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("No data", style: TextStyle(fontSize: 16)),
                    ),
                    Container(
                      width: 250,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: RaisedButton(
                        onPressed: () => _cardBloc.cardEventSink.add(FetchCardsEvent()),
                        color: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Text("Try again", style: theme.textTheme.button.copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _cardBloc = CardBloc();
  }
}
