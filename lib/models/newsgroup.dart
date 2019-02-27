class Newsgroup {
  String name;
  String description;

  Newsgroup(this.name, this.description);

  Newsgroup.fromString(String group) {
    List<String> split = group.split(RegExp(r'\s+'));
    name = split[0];
    description = split.sublist(1).join(' ');
  }

  Newsgroup.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    description = map['description'] ?? '';
  }

  bool operator ==(dynamic other) {
    if (other is Newsgroup)
      return name == other.name;
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  String get shortname {
    return name.startsWith('tu-graz.')
      ? name.startsWith('tu-graz.lv.')
        ? name.substring(11)
        : name.substring(8)
      : name;
  }
}
