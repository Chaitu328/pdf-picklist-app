// // services/pdf_extraction_service.dart
//
// import 'dart:io';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
//
// import '../app/modules/home/models/pick_list_item_model.dart';
//
// class PdfExtractionService {
//   /// Extracts PickList data from a GST PickList PDF file.
//   /// Uses Syncfusion PDF library for table extraction.
//   static Future<PickListData?> extractPickListData(File pdfFile) async {
//     try {
//       final bytes = await pdfFile.readAsBytes();
//       final PdfDocument document = PdfDocument(inputBytes: bytes);
//       final PdfTextExtractor extractor = PdfTextExtractor(document);
//       final String fullText = extractor.extractText();
//       document.dispose();
//
//       return _parsePickListText(fullText);
//     } catch (e) {
//       print('PDF extraction error: $e');
//       return null;
//     }
//   }
//
//   static PickListData _parsePickListText(String text) {
//     final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
//
//     // --- Extract header fields ---
//     String pickListNo = '';
//     String pickListDate = '';
//     String orderNo = '';
//     String orderDate = '';
//     String code = '';
//     String name = '';
//     String city = '';
//
//     for (int i = 0; i < lines.length; i++) {
//       final line = lines[i];
//
//       // Pick List No
//       final pickListMatch = RegExp(r'Pick List No\s+(\S+)').firstMatch(line);
//       if (pickListMatch != null) pickListNo = pickListMatch.group(1)!;
//
//       // Pick List Date
//       final pickDateMatch = RegExp(r'Pick List Date\s+(\d{2}/\d{2}/\d{4}\s+\d{2}:\d{2}:\d{2})').firstMatch(line);
//       if (pickDateMatch != null) pickListDate = pickDateMatch.group(1)!;
//
//       // Order No
//       final orderMatch = RegExp(r'Order No\s+(\S+)').firstMatch(line);
//       if (orderMatch != null) orderNo = orderMatch.group(1)!;
//
//       // Order Date
//       final orderDateMatch = RegExp(r'Order Date\s+(\d{2}/\d{2}/\d{4}\s+\d{2}:\d{2}:\d{2})').firstMatch(line);
//       if (orderDateMatch != null) orderDate = orderDateMatch.group(1)!;
//
//       // Code
//       if (line.startsWith('Code ')) {
//         final codeMatch = RegExp(r'Code\s+(\S+)').firstMatch(line);
//         if (codeMatch != null) code = codeMatch.group(1)!;
//       }
//
//       // Name
//       if (line.startsWith('Name ')) {
//         name = line.replaceFirst('Name', '').trim().split('  ').first.trim();
//       }
//
//       // City
//       if (line.startsWith('City ')) {
//         city = line.replaceFirst('City', '').trim();
//       }
//     }
//
//     // --- Extract table rows ---
//     // Rows start after the header row containing "Part Number Description"
//     // Pattern: starts with a number, followed by part data
//     final List<PickListItem> items = [];
//
//     // Find the data rows: lines starting with row numbers like "1 ", "2 ", etc.
//     final rowPattern = RegExp(
//       r'^(\d+)\s+'                            // S.No
//       r'([A-Z]{0,3})\s*'                      // Bin L1
//       r'([A-Z0-9\-]+)?\s*'                    // Bin L2
//       r'([A-Z0-9]+)?\s+'                      // Bin L3
//       r'([A-Z0-9]+)\s+'                       // Part Number
//       r'(.+?)\s+'                             // Description
//       r'(\d{8})\s+'                           // HSN No
//       r'(\d+)\s+'                             // MOQ
//       r'([\d,]+)\s+'                          // Stock on Hand
//       r'([\d,\.]+)\s+'                        // MRP
//       r'(\d+)\s+'                             // Order Qty
//       r'(\d+)',                               // Allocated Qty
//     );
//
//     // Simpler: Parse by known table structure using text blocks
//     final tableItems = _parseTableRows(lines);
//     items.addAll(tableItems);
//
//     return PickListData(
//       pickListNo: pickListNo,
//       pickListDate: pickListDate,
//       orderNo: orderNo,
//       orderDate: orderDate,
//       code: code,
//       name: name,
//       city: city,
//       items: items,
//     );
//   }
//
//   static List<PickListItem> _parseTableRows(List<String> lines) {
//     final List<PickListItem> items = [];
//
//     // Identify the start of table data - after the header row
//     int tableStart = -1;
//     for (int i = 0; i < lines.length; i++) {
//       if (lines[i].contains('Part Number') && lines[i].contains('Description')) {
//         tableStart = i + 2; // Skip header and sub-header (L1, L2, L3)
//         break;
//       }
//     }
//     if (tableStart == -1) return items;
//
//     // Each data row starts with a digit (S.No)
//     final rowStartPattern = RegExp(r'^\d+\s+');
//
//     // Collect multi-line rows
//     List<String> currentRowLines = [];
//     int currentSNo = 0;
//
//     for (int i = tableStart; i < lines.length; i++) {
//       final line = lines[i];
//
//       // Stop at footer
//       if (line.startsWith('Picked By') || line.startsWith('Checked By')) break;
//
//       if (rowStartPattern.hasMatch(line)) {
//         // Parse previous row
//         if (currentRowLines.isNotEmpty) {
//           final item = _parseRowLines(currentRowLines);
//           if (item != null) items.add(item);
//         }
//         currentRowLines = [line];
//       } else if (currentRowLines.isNotEmpty) {
//         // Continuation of previous row (multi-line description or part number)
//         currentRowLines.add(line);
//       }
//     }
//
//     // Parse last row
//     if (currentRowLines.isNotEmpty) {
//       final item = _parseRowLines(currentRowLines);
//       if (item != null) items.add(item);
//     }
//
//     return items;
//   }
//
//   static PickListItem? _parseRowLines(List<String> lines) {
//     final fullLine = lines.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
//
//     // Pattern to extract key fields from the combined line
//     // S.No [BinL1] [BinL2] [BinL3] PartNumber Description HSN MOQ Stock MRP OrderQty AllocQty [PickedQty]
//     final pattern = RegExp(
//         r'^(\d+)\s+'                                    // 1: S.No
//         r'(?:([A-Z]{2})\s+)?'                           // 2: Bin L1 (optional)
//         r'(?:([A-Z0-9\-]+)\s+)?'                        // 3: Bin L2 (optional)
//         r'(?:([A-Z0-9]+)\s+)?'                          // 4: Bin L3 (optional)
//         r'([A-Z0-9]+)\s+'                               // 5: Part Number
//         r'(.+?)\s+'                                     // 6: Description
//         r'(\d{8})\s+'                                   // 7: HSN No
//         r'(\d+)\s+'                                     // 8: MOQ
//         r'(\d+)\s+'                                     // 9: Stock on Hand
//         r'([\d,\.]+)\s+'                                // 10: MRP
//         r'(\d+)\s+'                                     // 11: Order Qty
//         r'(\d+)'                                        // 12: Allocated Qty
//     );
//
//     final match = pattern.firstMatch(fullLine);
//     if (match == null) return null;
//
//     return PickListItem(
//       sNo: match.group(1) ?? '',
//       binL1: match.group(2) ?? '',
//       binL2: match.group(3) ?? '',
//       binL3: match.group(4) ?? '',
//       partNumber: match.group(5) ?? '',
//       description: match.group(6) ?? '',
//       hsnNo: match.group(7) ?? '',
//       moq: match.group(8) ?? '',
//       stockOnHand: match.group(9) ?? '',
//       mrp: match.group(10) ?? '',
//       orderQty: match.group(11) ?? '',
//       allocatedQty: match.group(12) ?? '',
//       pickedQty: '',
//     );
//   }
// }