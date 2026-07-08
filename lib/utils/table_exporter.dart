import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class TableExporter {
  /// Checks if the markdown content contains a table structure.
  static bool hasTable(String markdown) {
    final regExp = RegExp(r'\|\s*:?-+:?\s*\|');
    return markdown.contains(regExp);
  }

  /// Parses markdown tables from the text and converts them into a CSV string.
  /// If there are multiple tables, it will extract the first one.
  static String? convertMarkdownToCsv(String markdown) {
    final lines = markdown.split('\n');
    final List<List<String>> csvRows = [];
    bool foundTable = false;

    for (var line in lines) {
      final trimmed = line.trim();
      
      // A table line must start and end with '|'
      if (!trimmed.startsWith('|') || !trimmed.endsWith('|')) {
        // If we were already parsing a table and the line doesn't match, we stop parsing.
        if (foundTable && csvRows.isNotEmpty) {
          break;
        }
        continue;
      }

      // Check if it's a separator line (e.g., |---|:---:|)
      final withoutPipes = trimmed.replaceAll('|', '').trim();
      final isSeparator = withoutPipes.isNotEmpty &&
          withoutPipes.split('').every((char) => char == '-' || char == ':' || char == ' ');
      
      if (isSeparator) {
        foundTable = true;
        continue;
      }

      // Parse cells
      final cells = trimmed.split('|');
      
      // Remove leading and trailing empty cells resulting from splitting '| cell |'
      if (cells.isNotEmpty && cells.first.trim().isEmpty) {
        cells.removeAt(0);
      }
      if (cells.isNotEmpty && cells.last.trim().isEmpty) {
        cells.removeLast();
      }

      final rowData = cells.map((cell) {
        // Clean cell and escape quotes for CSV
        var cleaned = cell.trim();
        if (cleaned.contains('"') || cleaned.contains(',') || cleaned.contains('\n')) {
          cleaned = cleaned.replaceAll('"', '""');
          cleaned = '"$cleaned"';
        }
        return cleaned;
      }).toList();

      if (rowData.isNotEmpty) {
        csvRows.add(rowData);
        foundTable = true;
      }
    }

    if (csvRows.isEmpty) return null;

    // Convert list of rows to a single CSV string
    // We prepend the UTF-8 BOM (\uFEFF) so Excel opens Thai characters correctly.
    final csvBuffer = StringBuffer('\uFEFF');
    for (var row in csvRows) {
      csvBuffer.writeln(row.join(','));
    }

    return csvBuffer.toString();
  }

  /// Exports the table found in [markdown] as a CSV file and opens the share panel.
  static Future<bool> exportTable(String markdown, String fileNamePrefix) async {
    try {
      final csvContent = convertMarkdownToCsv(markdown);
      if (csvContent == null || csvContent.isEmpty) {
        return false;
      }

      // Get temporary directory to save the file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${fileNamePrefix}_$timestamp.csv';
      final file = File('${tempDir.path}/$fileName');

      // Write contents as UTF-8
      await file.writeAsString(csvContent);

      // Open the native share/save panel
      final xFile = XFile(file.path, mimeType: 'text/csv');
      await Share.shareXFiles([xFile], subject: 'รายงานตารางข้อมูล');
      return true;
    } catch (e) {
      debugPrint('Error exporting table: $e');
      return false;
    }
  }
}
