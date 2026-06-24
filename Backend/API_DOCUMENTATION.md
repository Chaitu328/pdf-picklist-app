# PickList Backend API Documentation

Frontend handoff document for building the manager/admin panel.

## Overview

This backend is a Node.js/Express API backed by MongoDB. It manages users, picklists, worker assignment/scanning, delivery route imports, reports, and shortage notifications.

- Default server port: `3000`
- Production server URL: `https://pick-list.onrender.com`
- Production API base URL: `http://localhost:3000/api`
- Local development API base URL: `http://localhost:3000/api`
- Auth type: JWT Bearer token
- Token expiry: `7d`
- Realtime notifications: Socket.IO

## Deployment Smoke Check

Checked against the Render deployment:

- `GET http://localhost:3000/api/picklist` returns `401` without a token, as expected.
- `GET http://localhost:3000/api/delivery-routes` returns `401` without a token, as expected.
- `GET http://localhost:3000/api/users` is publicly reachable, matching the current backend code.

Authenticated create/update/download flows still need a valid manager or worker login to test end to end.

## Authentication

Most manager/admin API calls require this header:

```http
Authorization: Bearer <token>
Content-Type: application/json
```

Tokens are returned by `POST /api/register` and `POST /api/login`.

JWT payload contains:

```json
{
  "id": "user_mongodb_id",
  "role": "manager"
}
```

Current roles:

- `manager`
- `worker`

Important implementation note: the backend currently verifies that the token is valid, but most protected routes do not enforce role-based authorization. The frontend should still use roles to show/hide manager and worker screens.

## Common Error Responses

```json
{
  "message": "No token provided"
}
```

```json
{
  "message": "Invalid or expired token"
}
```

```json
{
  "message": "Server error",
  "error": "error details"
}
```

## Data Models

### User

```json
{
  "_id": "string",
  "name": "string",
  "email": "string",
  "role": "manager | worker",
  "timestamp": "ISO date"
}
```

### PickList

```json
{
  "_id": "string",
  "pick_list_no": "string",
  "order_number": "string",
  "picklist_date": "string",
  "route_day": "Monday | Tuesday | Wednesday | Thursday | Friday | Saturday | Sunday | Any",
  "clientId": {
    "_id": "string",
    "name": "string",
    "email": "string"
  },
  "workerId": {
    "_id": "string",
    "name": "string",
    "email": "string"
  },
  "status": "unassigned | assigned | processing | completed | completed_with_shortage",
  "parts": [
    {
      "_id": "string",
      "partno": "string",
      "description": "string",
      "req_qty": 10,
      "allo_qty": 0,
      "status": "pending | partial | shortage | excess | completed",
      "scanned_items": [
        {
          "_id": "string",
          "unique_id": "string | null",
          "entry_method": "QR | Manual",
          "scannedAt": "ISO date"
        }
      ]
    }
  ],
  "createdAt": "ISO date"
}
```

### DeliveryRoute

```json
{
  "_id": "string",
  "networkCode": "string",
  "companyName": "string",
  "city": "string",
  "deliveryDay": "string",
  "createdAt": "ISO date",
  "updatedAt": "ISO date"
}
```

`deliveryDay` may be a weekday, multiple weekdays separated by `&`, `LOCAL`, or `TRANSPORT`.

## User APIs

### Register User

Creates a manager or worker user and returns a JWT token.

```http
POST /api/register
```

Request body:

```json
{
  "name": "Manager Name",
  "email": "manager@example.com",
  "password": "password123",
  "role": "manager"
}
```

Success response: `201`

```json
{
  "message": "User registered successfully",
  "token": "jwt_token",
  "user": {
    "name": "Manager Name",
    "id": "user_id",
    "email": "manager@example.com",
    "role": "manager"
  }
}
```

Possible errors:

- `400` user already exists
- `500` server error

### Login User

Authenticates a user and returns a JWT token.

```http
POST /api/login
```

Request body:

```json
{
  "email": "manager@example.com",
  "password": "password123"
}
```

Success response: `200`

```json
{
  "message": "Login successful",
  "token": "jwt_token",
  "user": {
    "id": "user_id",
    "email": "manager@example.com",
    "role": "manager"
  }
}
```

Possible errors:

- `400` invalid credentials
- `500` server error

### Get All Users

Returns all users without password fields.

```http
GET /api/users
```

Auth: currently not required by backend.

Success response: `200`

```json
{
  "users": [
    {
      "_id": "user_id",
      "name": "Worker Name",
      "email": "worker@example.com",
      "role": "worker",
      "timestamp": "2026-04-23T00:00:00.000Z"
    }
  ]
}
```

Frontend use: manager user management screen, worker dropdowns, assignment visibility.

### Get All Workers

Returns only users whose role is `worker` (without password fields).

```http
GET /api/workers
```

Auth: currently not required by backend.

Success response: `200`

```json
{
  "workers": [
    {
      "_id": "user_id",
      "name": "Worker Name",
      "email": "worker@example.com",
      "role": "worker",
      "timestamp": "2026-04-23T00:00:00.000Z",
      "involvedPicklists": 12,
      "completedPicklists": 9,
      "pendingPicklists": 3
    }
  ]
}
```

Frontend use: worker list screen, worker assignment selectors, worker directory view.

## Picklist APIs

All picklist endpoints below require:

```http
Authorization: Bearer <token>
```

Exception: the two delete endpoints currently do not require auth in backend code.

### Create Picklist

Manager creates a new picklist.

```http
POST /api/picklist
```

Request body:

```json
{
  "pick_list_no": "PL-1001",
  "order_number": "ORD-5001",
  "picklist_date": "2026-04-23",
  "route_day": "Monday",
  "parts": [
    {
      "partno": "PART-001",
      "description": "Brake Pad",
      "req_qty": 5
    },
    {
      "partno": "PART-002",
      "description": "Oil Filter",
      "req_qty": 2
    }
  ]
}
```

Required fields:

- `pick_list_no`
- `order_number`
- `parts[].partno`
- `parts[].req_qty`

Optional defaults:

- `picklist_date`: `"Not provided"`
- `route_day`: `"Any"`
- `parts[].allo_qty`: `0`
- `parts[].status`: `"pending"`

Success response: `201`

Returns the created PickList object.

Possible errors:

- `400` order number missing
- `400` picklist already exists
- `401` no token
- `403` invalid token
- `500` server error

### Get All Picklists

Returns all picklists with manager/client and worker details populated.

```http
GET /api/picklist
```

Success response: `200`

```json
[
  {
    "_id": "picklist_id",
    "pick_list_no": "PL-1001",
    "order_number": "ORD-5001",
    "picklist_date": "2026-04-23",
    "route_day": "Monday",
    "clientId": {
      "_id": "manager_id",
      "name": "Manager Name",
      "email": "manager@example.com"
    },
    "workerId": null,
    "status": "unassigned",
    "parts": []
  }
]
```

Sorting behavior: picklists whose `route_day` matches the current server weekday are moved to the top.

Frontend use: manager dashboard, picklist list/table, today priority section.

### Assign Picklist

Assigns the logged-in user as worker if the picklist is not already assigned.

```http
PATCH /api/picklist/:id/assign
```

Path params:

- `id`: MongoDB `_id` of the picklist

Request body: none

Success response: `200`

Returns updated PickList object with:

```json
{
  "workerId": "logged_in_user_id",
  "status": "assigned"
}
```

Possible errors:

- `400` picklist already assigned or not found
- `401` no token
- `403` invalid token
- `500` server error

Frontend use: worker claim button. For an admin panel, this can be shown as operational status even though the current API does not support assigning another selected worker.

### Scan One Item

Processes one scanned or manually entered item for a picklist part.

```http
PATCH /api/picklist/:id/scan
```

Request body for QR scan:

```json
{
  "partno": "PART-001",
  "unique_id": "QR-UNIQUE-123",
  "entry_method": "QR"
}
```

Request body for manual entry:

```json
{
  "partno": "PART-001",
  "entry_method": "Manual"
}
```

Success response: `200`

Returns the updated PickList object.

Backend behavior:

- Rejects duplicate QR `unique_id` across all parts in the picklist.
- Rejects scan if `allo_qty >= req_qty`.
- Increments `allo_qty` by `1`.
- Adds a `scanned_items` entry.
- Sets part status to `partial` or `completed`.
- Sets picklist status to `processing`.

Possible errors:

- `400` duplicate QR scan
- `400` allocated quantity already equals/exceeds required quantity
- `404` picklist not found
- `404` part not found in this picklist
- `500` server error

### Proceed With Shortage

Finalizes a picklist even if some required quantities were not allocated.

```http
POST /api/picklist/:id/proceed
```

Request body: none

Success response: `200`

```json
{
  "message": "Picklist finalized",
  "picklist": {
    "_id": "picklist_id",
    "status": "completed_with_shortage"
  }
}
```

Backend behavior:

- Parts with `allo_qty < req_qty` become `shortage`.
- Picklist status becomes `completed_with_shortage` if any items are missing.
- Picklist status becomes `completed` if no items are missing.
- Emits Socket.IO event `shortage_alert` when there is a shortage.

Frontend use: worker completion flow and manager shortage notification dashboard.

### Download Picklist Excel Report

Downloads scan history for one picklist as Excel.

```http
GET /api/picklist/:id/report/excel
```

Response:

- Content type: `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
- Attachment filename: `Report-<pick_list_no>.xlsx`

Frontend implementation: call with Bearer token and handle as a file/blob download.

### Download Picklist CSV Report

Downloads scan history for one picklist as CSV.

```http
GET /api/picklist/:id/report/csv
```

Response:

- Content type: `text/csv`
- Attachment filename: `Report-<pick_list_no>.csv`

Frontend implementation: call with Bearer token and handle as a file/blob download.

### Download Global Excel Report

Downloads all picklists and scan history in one Excel file.

```http
GET /api/picklist/report/all/excel
```

Response:

- Content type: `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`
- Attachment filename: `Global-Warehouse-Report.xlsx`

Frontend use: manager/admin master report export button.

### Delete All Picklists

Deletes every picklist.

```http
DELETE /api/picklist/delete
```

Auth: currently not required by backend.

Success response: `200`

```json
{
  "message": "All picklists deleted",
  "deletedCount": 10
}
```

Frontend warning: this is destructive and should be hidden behind confirmation. Backend should ideally protect this route before production.

### Delete Picklist By Number

Deletes a picklist using `pick_list_no`, not MongoDB `_id`.

```http
DELETE /api/picklist/:pickListNumber
```

Example:

```http
DELETE /api/picklist/PL-1001
```

Auth: currently not required by backend.

Success response: `200`

```json
{
  "message": "PickList PL-1001 deleted."
}
```

Possible errors:

- `400` picklist number required
- `404` picklist not found
- `500` server error

## Delivery Route APIs

All delivery route endpoints require:

```http
Authorization: Bearer <token>
```

### Import Delivery Routes From Excel

Imports delivery routes from an Excel workbook.

```http
POST /api/delivery-routes/import
```

Headers:

```http
Authorization: Bearer <token>
Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
```

Body:

Raw `.xlsx` binary file.

Expected Excel columns:

| Column | Field |
| --- | --- |
| A | networkCode |
| B | companyName |
| C | city |
| D | deliveryDay |

The first row is skipped as a header row.

Success response: `201`

```json
{
  "message": "Delivery routes imported successfully",
  "importedCount": 25
}
```

Possible errors:

- `400` file is not raw Excel binary
- `400` no delivery route rows found
- `409` duplicate records found while importing
- `500` server error

Frontend implementation note: send the file as an `ArrayBuffer`/`Blob`, not as JSON or multipart form-data.

### Get Delivery Routes Grouped By Day

Returns delivery routes grouped for display.

```http
GET /api/delivery-routes
```

Success response: `200`

```json
{
  "dayOrder": ["Monday", "Tuesday", "Wednesday"],
  "grouped": [
    {
      "day": "Monday",
      "routes": [
        {
          "_id": "route_id",
          "networkCode": "N001",
          "companyName": "ABC Motors",
          "city": "Mumbai",
          "deliveryDay": "Monday"
        }
      ]
    }
  ],
  "specialGroups": [
    {
      "type": "LOCAL",
      "routes": []
    },
    {
      "type": "TRANSPORT",
      "routes": []
    }
  ],
  "incompleteRoutes": []
}
```

Grouping behavior:

- Normal weekdays are grouped under `grouped`.
- `LOCAL` and `TRANSPORT` are grouped under `specialGroups`.
- Missing or unrecognized values are returned under `incompleteRoutes`.
- Multiple days can be stored as `Monday & Thursday`.
- Day order is calculated by the backend relative to the current server day.

Frontend use: manager route planning screen, route-day lookup when creating picklists.

## Socket.IO Notifications

Connect to the backend server root, not `/api`.

```js
import { io } from "socket.io-client";

const socket = io("https://pick-list.onrender.com");

socket.on("shortage_alert", (payload) => {
  console.log(payload);
});
```

Event: `shortage_alert`

Payload:

```json
{
  "message": "A worker proceeded with an incomplete picklist.",
  "pick_list_no": "PL-1001",
  "items_missing": 3
}
```

Frontend use: manager dashboard toast, notification list, shortage alert badge.

## Recommended Admin Panel Screens

### Login

- Email/password login
- Store JWT token securely for authenticated API calls
- Redirect based on `user.role`

### Manager Dashboard

- Summary cards:
  - Total picklists
  - Unassigned picklists
  - Assigned/processing picklists
  - Completed with shortage
- Realtime shortage alert listener via Socket.IO
- Today-priority picklists using `GET /api/picklist`

### Picklist Management

- Create picklist form
- Picklist table with filters:
  - status
  - route day
  - worker
  - pick list number
  - order number
- Detail view:
  - parts required vs allocated
  - scan history
  - status badges
  - report download buttons
- Delete action with confirmation

### Reports

- Per-picklist Excel download
- Per-picklist CSV download
- Global warehouse Excel download

### Delivery Routes

- Excel import screen
- Grouped route display by weekday
- Special sections for `LOCAL` and `TRANSPORT`
- Incomplete/unrecognized route data review

### User Management

- View managers/workers from `GET /api/users`
- View only workers from `GET /api/workers`
- Register users through `POST /api/register`

## Frontend Integration Notes

### File Download Example

```js
async function downloadReport(picklistId, token) {
  const response = await fetch(
    `http://localhost:3000/api/picklist/${picklistId}/report/excel`,
    {
      headers: {
        Authorization: `Bearer ${token}`
      }
    }
  );

  const blob = await response.blob();
  const url = window.URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = "picklist-report.xlsx";
  link.click();
  window.URL.revokeObjectURL(url);
}
```

### Excel Import Example

```js
async function importDeliveryRoutes(file, token) {
  const response = await fetch("http://localhost:3000/api/delivery-routes/import", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    },
    body: file
  });

  return response.json();
}
```

### Protected API Helper Example

```js
const API_BASE_URL = "http://localhost:3000/api";

async function apiFetch(path, token, options = {}) {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
      ...(options.headers || {})
    }
  });

  const contentType = response.headers.get("content-type") || "";
  const data = contentType.includes("application/json")
    ? await response.json()
    : await response.blob();

  if (!response.ok) {
    throw data;
  }

  return data;
}
```

## Backend Gaps To Consider Before Production

These are not frontend blockers, but the frontend developer and backend owner should know them:

- `GET /api/users` is not protected.
- `DELETE /api/picklist/delete` is not protected.
- `DELETE /api/picklist/:pickListNumber` is not protected.
- Protected routes validate JWT but do not enforce manager vs worker permissions.
- There is no API to assign a picklist to a selected worker; assignment always uses the logged-in user.
- Delivery route import does not clear old routes before inserting new ones.
- Delivery route schema has no unique index, so duplicate import behavior depends on MongoDB constraints not shown in the current model.
- User registration accepts any role from the client if it matches the enum.
