import 'dart:convert';
import 'dart:io';
import 'package:lead_manager/models/lead.dart';
import 'package:path_provider/path_provider.dart';

class ExportService {
  // Generate JSON string from lead list
  static String generateJson(List<Lead> leads) {
    List<Map<String, dynamic>> data =
        leads.map((lead) => lead.toMap()).toList();
    return jsonEncode(data);
  }

  // Save JSON file locally and return the file path
  static Future<File> saveJsonFile(String jsonContent) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/leads_export.json";

    final file = File(path);
    return file.writeAsString(jsonContent);
  }
}
