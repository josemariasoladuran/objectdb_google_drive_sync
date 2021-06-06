import 'dart:io';

import 'package:objectdb/objectdb.dart';
import 'package:objectdb/src/objectdb_meta.dart';
import 'package:objectdb/src/objectdb_storage_filesystem.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleDriveStorage extends FileSystemStorage {
  final String _localPath;
  final String _drivePath;
  final drive.DriveApi _driveApi;

  GoogleDriveStorage(
      this._localPath, this._drivePath, http.Client googleAuthClient)
      : _driveApi = drive.DriveApi(googleAuthClient),
        super(_localPath);

  @override
  Future<Meta> open([int version = 1]) async {
    return super.open();
  }

  @override
  Future<ObjectId> insert(Map data) async {
    var result = await super.insert(data);
    await _uploadGoogleDrive();
    return result;
  }

  @override
  Future remove(Map query) async {
    var count = await super.remove(query);
    await _uploadGoogleDrive();
    return count;
  }

  @override
  Future update(Map query, Map changes, [bool replace = false]) async {
    var count = await super.update(query, changes, replace);
    await _uploadGoogleDrive();
    return count;
  }

  Future<void> _uploadGoogleDrive() async {
    var driveFile = drive.File();
    driveFile.name = _drivePath;

    var fileToUpload = File(_localPath);

    // *********************************
    // FIXME: Update file if exists yet!!!
    // *********************************
    
    // Create a new back-up file on google drive.
    await _driveApi.files.create(driveFile, uploadMedia: drive.Media(fileToUpload.openRead(), fileToUpload.lengthSync()));
  }
}
