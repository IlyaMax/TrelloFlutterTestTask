class BoardCard {
  int id;
  int groupIndex;
  String text;
  static const groupNames = ["On hold", "In progress", "Needs review", "Approved"];

  BoardCard.fromMap(Map map) {
    this.id = map["id"];
    this.groupIndex = int.parse(map["row"]);
    this.text = map["text"];
  }
}
