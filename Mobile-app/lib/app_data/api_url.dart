class ApiConstants {
  static const String baseURL = "http://161.248.223.165:3027/api";

  static const String loginEndPoint = "$baseURL/login";
  static const String registrationEndPoint = "$baseURL/register";
  static const String postToPickList = "$baseURL/picklist";
  static const String getPickList = "$baseURL/picklist/";
  static String assignPickList(String id) => "$baseURL/picklist/$id/assign";
  static String scanPickList(String id) => "$baseURL/picklist/$id/scan";
  static const String deletePickList = "$baseURL/picklist/delete/";
  static String proceedPickList(String id) => "$baseURL/picklist/$id/proceed";
  static String deliverRoutes = "$baseURL/delivery-routes";

  // Inward endpoints
  static const String inward = "$baseURL/inward";
  static const String getInward = "$baseURL/inward/";
  static String assignInward(String id) => "$baseURL/inward/$id/assign";
  static String scanInward(String id) => "$baseURL/inward/$id/scan";
  static String completeInward(String id) => "$baseURL/inward/$id/complete";

  // Audit endpoints
  static const String auditUserEvents = "$baseURL/audit/user-events";
  static const String auditRouteEvents = "$baseURL/audit/route-events";
  static const String auditManagerProgress = "$baseURL/audit/manager-progress";
  static const String auditWorkerProgress = "$baseURL/audit/worker-progress";
}