@Timeout(Duration(seconds: 5000))

import 'dart:io';
import 'package:dotenv/dotenv.dart' show load, env;
import 'package:objectdb/objectdb.dart';
import 'package:objectdb_google_drive_sync/objectdb_google_drive.dart';
import 'package:test/test.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/drive/v3.dart' as drive;

void main() {
  test('Synchronize database in Google Drive', () async {
    //Load environment var .env file
    load();

    var googleAuthClient = await clientViaUserConsent(
        ClientId(env['GOOGLE_TEST_APP_CLIENT_ID'], env['GOOGLE_TEST_APP_CLIENT_SECRET']),
        [drive.DriveApi.driveScope], (url) {
      print('Please go to the following URL and grant access:');
      print('  => $url"');
      print('');
    });

    final localPath = Directory.current.path + '/test.objectdb';
    final db =
        GoogleDriveObjectDB(localPath, 'test.objectdb', googleAuthClient);

    // insert document into database
    await db.insert({
      'name': {'first': 'Jose Maria', 'last': 'Sola Duran'},
      'age': 28,
      'active': true
    });
    await db.insert({
      'name': {'first': 'Francisco', 'last': 'Fernandez Jimenez'},
      'age': 18,
      'active': false
    });

    // update documents
    await db.update({
      Op.gte: {'age': 80}
    }, {
      'active': false
    });

    // remove documents
    await db.remove({'active': false});

    // search documents in database
    var result = await db.find({'active': true, 'name.first': 'Jose Maria'});

    expect(result.isNotEmpty, equals(true));
    // cleanup the db file
    // await db.cleanup();

    // close db
    await db.close();
  });
}
