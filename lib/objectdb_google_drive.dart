import 'package:objectdb/objectdb.dart';
import 'package:http/http.dart' as http;

import 'internal/objectdb_google_drive_storage.dart';

class GoogleDriveObjectDB extends ObjectDB {
  
  GoogleDriveObjectDB(
      String _localPath, String _drivePath, http.Client googleAuthClient)
      : super(GoogleDriveStorage(_localPath, _drivePath, googleAuthClient));

  GoogleDriveObjectDB.fromGoogleDriveStorage(GoogleDriveStorage _googleDriveStorage) : super(_googleDriveStorage);
}
