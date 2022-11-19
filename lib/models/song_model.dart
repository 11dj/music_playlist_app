import 'dart:convert';

List<SongModel> songModelFromMap(String str) =>
    json.decode(str).map((x) => SongModel.fromMap(x));

String songModelToMap(List<SongModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class SongModel {
  SongModel({
    this.filename,
    this.trackname,
    this.artist,
  });

  String? filename;
  String? trackname;
  String? artist;

  factory SongModel.fromMap(Map<String, dynamic> json) => SongModel(
        filename: json["filename"],
        trackname: json["trackname"],
        artist: json["artist"],
      );

  Map<String, dynamic> toMap() => {
        "filename": filename,
        "trackname": trackname,
        "artist": artist,
      };
}
