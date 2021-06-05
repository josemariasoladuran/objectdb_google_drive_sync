@Timeout(Duration(seconds: 5000))

import 'dart:io';

import 'package:objectdb/objectdb.dart';
import 'package:objectdb_google_drive_sync/objectdb_google_drive_storage.dart';
import 'package:test/test.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/drive/v3.dart' as drive;

void main() {
  test('Synchronize database in Google Drive', () async {

    var id = ClientId('707287005811-1b4cl8jpck8ickkpsfgj1039p0hu2umu.apps.googleusercontent.com', 'zVt3fgosxHwLdScpblWURxX2');
    var scopes = [drive.DriveApi.driveScope];
  
    var googleAuthClient = await clientViaUserConsent(id, scopes, (url) {
        print('Please go to the following URL and grant access:');
        print('  => $url"');
        print('');
      });

    final localPath = Directory.current.path + '/test.objectdb';
    final db = ObjectDB(GoogleDriveStorage(localPath, 'test.objectdb', googleAuthClient));
    
    // insert document into database
    await db.insert({'name': {'first': 'Some', 'last': 'Body'}, 'age': 18, 'active': true});
    await db.insert({'name': {'first': 'Someone', 'last': 'Else'}, 'age': 25, 'active': false});

    // update documents
    await db.update({Op.gte: {'age': 80}}, {'active': false});

    // remove documents
    await db.remove({'active': false});

    // search documents in database
    var result = await db.find({'active': true, 'name.first': 'Some'});

    expect(result.isNotEmpty, equals(true));
    // cleanup the db file
    // await db.cleanup();

    // close db
    await db.close();
});
}