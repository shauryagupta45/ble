// To parse this JSON data, do
//
//     final terminal = terminalFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

Terminal terminalFromJson(String str) => Terminal.fromJson(json.decode(str));

String terminalToJson(Terminal data) => json.encode(data.toJson());

class Terminal {
  Terminal({
    this.h,
    this.baV,
    this.ba,
    // this.acd,
    // this.aev,
    // this.atm,
    // this.abv,
    // this.lat,
    // this.lon,
    // this.pit,
    // this.rol,
    // this.clv,
    // this.btm,
    // this.cur,
    // this.cap,
    // this.bst,
    // this.tov,
  });

  var ba;
  var baV;
  var h;
  // var acd;
  // var aev;
  // var atm;
  // var abv;
  // var lat;
  // var lon;
  // var pit;
  // var rol;
  // List<dynamic>? clv;
  // List<dynamic>? btm;
  // var cur;
  // var cap;
  // var bst;
  // var tov;

  factory Terminal.fromJson(Map<String, dynamic> json) => Terminal(
        ba: json["ba%"] == null ? null : json["ba%"],
        baV: json["baV"] == null ? null : json["baV"].toDouble(),
        h: json["h"] == null ? null : json["h"].toDouble(),
        // acd: json["acd"] == null ? null : json["acd"].toDouble(),
        // aev: json["aev"] == null ? null : json["aev"].toDouble(),
        // atm: json["atm"] == null ? null : json["atm"],
        // abv: json["abv"] == null ? null : json["abv"].toDouble(),
        // lat: json["lat"] == null ? null : json["lat"].toDouble(),
        // lon: json["lon"] == null ? null : json["lon"].toDouble(),
        // pit: json["pit"] == null ? null : json["pit"],
        // rol: json["rol"] == null ? null : json["rol"],
        // clv: json["clv"] == null
        //     ? null
        //     : List<dynamic>.from(json["clv"].map((x) => x)),
        // btm: json["btm"] == null
        //     ? null
        //     : List<dynamic>.from(json["btm"].map((x) => x)),
        // cur: json["cur"] == null ? null : json["cur"],
        // cap: json["cap"] == null ? null : json["cap"],
        // bst: json["bst"] == null ? null : json["bst"],
        // tov: json["tov"] == null ? null : json["tov"],
      );

  Map<String, dynamic> toJson() => {
        "ba%": ba == null ? null : ba,
        "baV": baV == null ? null : baV,
        "h": h == null ? null : h,
        // "acd": acd == null ? null : acd,
        // "aev": aev == null ? null : aev,
        // "atm": atm == null ? null : atm,
        // "abv": abv == null ? null : abv,
        // "lat": lat == null ? null : lat,
        // "lon": lon == null ? null : lon,
        // "pit": pit == null ? null : pit,
        // "rol": rol == null ? null : rol,
        // "clv": clv == null ? null : List<dynamic>.from(clv!.map((x) => x)),
        // "btm": btm == null ? null : List<dynamic>.from(btm!.map((x) => x)),
        // "cur": cur == null ? null : cur,
        // "cap": cap == null ? null : cap,
        // "bst": bst == null ? null : bst,
        // "tov": tov == null ? null : tov,
      };
}
