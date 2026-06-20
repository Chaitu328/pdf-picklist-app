// To parse this JSON data, do
//
//     final deliveryRoutesModel = deliveryRoutesModelFromJson(jsonString);

import 'dart:convert';

DeliveryRoutesModel deliveryRoutesModelFromJson(String str) => DeliveryRoutesModel.fromJson(json.decode(str));

String deliveryRoutesModelToJson(DeliveryRoutesModel data) => json.encode(data.toJson());

class DeliveryRoutesModel {
    List<String>? dayOrder;
    List<Grouped>? grouped;
    List<SpecialGroup>? specialGroups;
    List<dynamic>? incompleteRoutes;

    DeliveryRoutesModel({
        this.dayOrder,
        this.grouped,
        this.specialGroups,
        this.incompleteRoutes,
    });

    factory DeliveryRoutesModel.fromJson(Map<String, dynamic> json) => DeliveryRoutesModel(
        dayOrder: json["dayOrder"] == null ? [] : List<String>.from(json["dayOrder"]!.map((x) => x)),
        grouped: json["grouped"] == null ? [] : List<Grouped>.from(json["grouped"]!.map((x) => Grouped.fromJson(x))),
        specialGroups: json["specialGroups"] == null ? [] : List<SpecialGroup>.from(json["specialGroups"]!.map((x) => SpecialGroup.fromJson(x))),
        incompleteRoutes: json["incompleteRoutes"] == null ? [] : List<dynamic>.from(json["incompleteRoutes"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "dayOrder": dayOrder == null ? [] : List<dynamic>.from(dayOrder!.map((x) => x)),
        "grouped": grouped == null ? [] : List<dynamic>.from(grouped!.map((x) => x.toJson())),
        "specialGroups": specialGroups == null ? [] : List<dynamic>.from(specialGroups!.map((x) => x.toJson())),
        "incompleteRoutes": incompleteRoutes == null ? [] : List<dynamic>.from(incompleteRoutes!.map((x) => x)),
    };
}

class Grouped {
    String? day;
    List<Route>? routes;

    Grouped({
        this.day,
        this.routes,
    });

    factory Grouped.fromJson(Map<String, dynamic> json) => Grouped(
        day: json["day"],
        routes: json["routes"] == null ? [] : List<Route>.from(json["routes"]!.map((x) => Route.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "day": day,
        "routes": routes == null ? [] : List<dynamic>.from(routes!.map((x) => x.toJson())),
    };
}

class Route {
    String? id;
    String? networkCode;
    String? companyName;
    String? city;
    String? deliveryDay;
    DateTime? createdAt;
    DateTime? updatedAt;
    int? v;

    Route({
        this.id,
        this.networkCode,
        this.companyName,
        this.city,
        this.deliveryDay,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Route.fromJson(Map<String, dynamic> json) => Route(
        id: json["_id"],
        networkCode: json["networkCode"],
        companyName: json["companyName"],
        city: json["city"],
        deliveryDay: json["deliveryDay"]?.toString(),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "networkCode": networkCode,
        "companyName": companyName,
        "city": city,
        "deliveryDay": deliveryDay,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
    };
}

class SpecialGroup {
    String? type;
    List<Route>? routes;

    SpecialGroup({
        this.type,
        this.routes,
    });

    factory SpecialGroup.fromJson(Map<String, dynamic> json) => SpecialGroup(
        type: json["type"]?.toString(),
        routes: json["routes"] == null ? [] : List<Route>.from(json["routes"]!.map((x) => Route.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "routes": routes == null ? [] : List<dynamic>.from(routes!.map((x) => x.toJson())),
    };
}

