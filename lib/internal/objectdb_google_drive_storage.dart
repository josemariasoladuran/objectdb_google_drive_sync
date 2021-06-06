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

  File _localFile;
  String _driveFileId;

  GoogleDriveStorage(
      this._localPath, this._drivePath, http.Client googleAuthClient)
      : _driveApi = drive.DriveApi(googleAuthClient),
        _localFile = File(_localPath),
        super(_localPath);

  @override
  Future<Meta> open([int version = 1]) async {
    var responseQuery = await _driveApi.files.list(q: "name='$_drivePath' and trashed = false");
    if (responseQuery.files.isNotEmpty) {
      // FIXME: Download file if exists in remote Google Drive Storage
      // driveFileContentStream.stream
      
      _driveFileId = responseQuery.files[0].id;
      var driveFileContentStream = await _driveApi.files.get(_driveFileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      if (await _localFile.exists()) {
        await _localFile.delete();
      }
      await for (var value in driveFileContentStream.stream) {
        await _localFile.writeAsBytes(value, mode: FileMode.append, flush: true);
      }      
    }
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

    // Create a new back-up file on google drive.
    var localFile = File(_localPath);
    var uploadMedia =
        drive.Media(localFile.openRead(), await localFile.length());
    if (_driveFileId != null) {
      await _driveApi.files
          .update(driveFile, _driveFileId, uploadMedia: uploadMedia);
    } else {
      var result =
          await _driveApi.files.create(driveFile, uploadMedia: uploadMedia);
      _driveFileId = result.id;
    }
  }
}
