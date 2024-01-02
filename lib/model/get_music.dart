import 'dart:convert';

List<Music> musicFromJson(String str) =>
    List<Music>.from(json.decode(str).map((x) => Music.fromJson(x)));

String musicToJson(List<Music> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Music {
  String id;
  String name;
  String image;
  String link;

  Music({
    required this.id,
    required this.name,
    required this.image,
    required this.link,
  });

  Music copyWith({
    String? id,
    String? name,
    String? image,
    String? link,
  }) =>
      Music(
        id: id ?? this.id,
        name: name ?? this.name,
        image: image ?? this.image,
        link: link ?? this.link,
      );

  factory Music.fromJson(Map<String, dynamic> json) => Music(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        link: json["link"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "link": link,
      };

  static musicFromJson(Music data) {}
}
