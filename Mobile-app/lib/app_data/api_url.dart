class ApiConstants {
  static const String baseURL = "http://161.248.223.165:3027/api";

  static const String loginEndPoint = "$baseURL/login";
  static const String registrationEndPoint = "$baseURL/register";
  static const String postToPickList = "$baseURL/picklist";
  static const String getPickList = "$baseURL/picklist/";
  static String assignPickList(String id) => "$baseURL/picklist/$id/assign";
  static String scanPickList(String id) => "$baseURL/picklist/$id/scan";
  static String setPartQuantity(String id) => "$baseURL/picklist/$id/set-quantity";
  static const String deletePickList = "$baseURL/picklist/delete/";
  static String proceedPickList(String id) => "$baseURL/picklist/$id/proceed";
  static String deliverRoutes = "$baseURL/delivery-routes";
}