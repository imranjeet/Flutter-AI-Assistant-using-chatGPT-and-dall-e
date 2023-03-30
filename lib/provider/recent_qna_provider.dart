import 'package:myassistant/services/custom_logger.dart';
import 'package:myassistant/services/locator.dart';
import 'package:sqflite/sqflite.dart';
import 'package:myassistant/services/db_services.dart';
import 'package:myassistant/provider/apiResponse.dart';

class RecentQnAProvider {
  Database db = locator<DBService>().db;

  Future<void> saveRecentQnA(String question, String answer, String typeQue) async {
    await db.transaction((txn) async {
      await txn.rawQuery(
          '''INSERT OR REPLACE INTO qnaData (question, answer, typeQue)values (? ,? , ?)''',
          [question, answer, typeQue]);
    });
    CustomLogger.instance.singleLine('Recent qnaData saved!');
  }

  Future<ProviderResponse<List<dynamic>>> getRecentQnA() async {
    var result = (await db.rawQuery('select * from qnaData ORDER BY id DESC LIMIT 30'));

    if (result.isNotEmpty) {
      return ProviderResponse.completed(data: result.map((e) => e).toList());
    }
    return ProviderResponse.error("No data ");
  }

  Future<void> deleteAllRecentQnA() async {
    await db.rawDelete("Delete from qnaData");
  }
}
