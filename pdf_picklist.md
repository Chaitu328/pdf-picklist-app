**Picklist Upload & Scanning System\
Functional Overview**

**Prepared By: VBLP TechSolutions Pvt Ltd**

**Project Name: Inventory & Picklist Management System**

1.  **Picklist Definition**

Each uploaded PDF is treated as one Picklist.

A picklist contains:

-   Picklist Number

-   Order Number

-   Picklist Date / Order Date

-   Multiple Part Numbers with required quantities

Each picklist is independent and processed separately.

1.  **Picklist Upload (Admin Side)**

Admin will upload Picklist PDF.

The following fields are mandatory while saving:

-   Picklist Number

-   Order Number

-   Either Picklist Date or Order Date

PDF may contain any number of part numbers (e.g., 3, 6, 11, or 400+
items).

Admin will also have options to:

-   Delete data based on a specific picklist

-   Delete all data if required

1.  **Picklist Data Handling**

After PDF upload:

-   System extracts Part Numbers and Required Quantities

-   Extracted data becomes the reference for validation

Each picklist can contain multiple different part numbers.

Same part number can appear in different picklists, but there is no
connection between them.

1.  **Picking Process (Worker Side)**

Workers will perform picking using:

-   QR Code Scanning

-   Manual Quantity Entry (if QR is not available)

If QR code is not scanned:

-   The system must record the item as \"NOT Scanned\"

Each QR contains:

-   Part Number

-   Unique ID (UPI Code)

1.  **QR Parsing Logic**

On scanning QR, system must extract:

-   Part Number

-   Unique ID

Each scan represents one physical item.

1.  **Scanning & Validation Logic**

Part Number is used to validate whether the item belongs to the
picklist.

Unique ID is used to identify each individual item.

System behavior:

-   Each scan = 1 item

-   Same Unique ID cannot be counted multiple times

-   Duplicate scan must be rejected with message

If scanned part is not part of the picklist:

-   System must reject the scan and show error

1.  **Quantity Handling**

Internally:

-   Each item is tracked individually using Unique ID

UI:

-   Quantity is shown as combined

Example:\
Required: 3\
Scanned: 2\
Display: 2 / 3

1.  **Validation Result**

System compares scanned quantity with required quantity:

-   Equal → Completed

-   Less → Shortage

-   More → Excess

Completed items must be highlighted in green.

1.  **Data Persistence**

All scanned data must be saved continuously.

In case of:

-   App restart

-   Device issue

Previously scanned data must not be lost.

User should continue from last state.

1.  **Assignment & Tracking**

After admin uploads picklist:

-   Worker can assign the picklist to himself

System will track:

-   Which worker is handling which picklist

Admin can view assignment details.

1.  **Admin Monitoring & Reports**

Admin should be able to:

-   Track picklist progress

-   View scanned vs required quantities

-   Identify shortages and excess

-   Download reports with full history

1.  **Incomplete Scan Handling & Notification**

If required items are not fully scanned:

-   System must show warning:\
    \"Some items are not scanned against required quantity. Do you want
    to proceed?\"

Worker options:

-   Proceed

-   Cancel and continue scanning

If worker proceeds:

-   System allows continuation

-   Admin is notified

Notification should include:

-   Picklist details

-   Number of items not scanned

1.  **PJP (Permanent Journey Plan) -- Priority Logic**

System must support PJP-based prioritization.

-   Customers are mapped to specific routes and days

-   Each picklist belongs to a customer

System behavior:

-   Identify customer from picklist

-   Match with PJP plan

-   Prioritize picklists based on current day

Example:\
If today is Monday →\
Only picklists belonging to Monday route customers should be prioritized

When multiple picklists are available:

-   System should guide worker to pick priority orders first

14\. **Technical Requirements**

The system should support both mobile and web-based operations.

Core technical requirements:

-   QR Code scanning capability using mobile camera

-   PDF parsing to extract picklist data

-   Local storage for offline data persistence

-   Background sync mechanism when internet is available

-   Duplicate detection using Unique ID

-   Real-time validation against picklist data

-   Secure user authentication for Admin and Worker roles

-   API-based communication between mobile app and backend

-   Error handling for invalid scans and data mismatches

Performance requirements:

-   Scanning should be fast and responsive

-   System should handle large picklists (100+ items)

-   Data should not be lost during app crash or restart

-   Offline mode should support full picking flow

15\. System Requirements

Mobile Application:

-   Android devices (primary support)

-   Camera access for QR scanning

-   Local database for offline storage

Backend System:

-   Server to manage picklists, users, and scan data

-   APIs for data sync, validation, and reporting

-   Database to store:

    -   Picklists

    -   Scanned items

    -   User assignments

    -   Reports

Admin Panel:

-   Web-based interface

-   Upload PDF picklists

-   View reports and tracking

-   Manage users and assignments

16\. Technology Stack

Frontend (Mobile App):

-   Flutter

Backend:

-   Node.js (or any scalable backend framework)

Database:

-   MongoDB / PostgreSQL

PDF Processing:

-   PDF parsing library (server-side or mobile-side)

QR Scanning:

-   Mobile camera + QR scanning library

Authentication:

-   JWT / Token-based authentication

Hosting / Deployment:

-   Cloud server (VPS)
