class ApiConstants {
  static const String baseURL = "https://pick-list.onrender.com/api";

  static const String loginEndPoint = "$baseURL/login";
  static const String registrationEndPoint = "$baseURL/register";
  static const String postToPickList = "$baseURL/picklist";
  static const String getPickList = "$baseURL/picklist/";
  static String assignPickList(String id) => "$baseURL/picklist/$id/assign";
  static String scanPickList(String id) => "$baseURL/picklist/$id/scan";
  static const String deletePickList = "$baseURL/picklist/delete/";
}