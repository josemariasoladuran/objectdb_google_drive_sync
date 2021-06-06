import 'dart:io';

import 'package:objectdb/objectdb.dart';
import 'package:objectdb/src/objectdb_meta.dart';
import 'package:objectdb/src/objectdb_storage_filesystem.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleDriveStorage extends FileSystemStorage {
  final File _localFile;
  final String _drivePath;
  final drive.DriveApi _driveApi;
  final bool _encrypt;

  String _driveFileId;

  GoogleDriveStorage(
      String _localPath, this._drivePath, http.Client googleAuthClient, { bool encrypt = false })
      : _driveApi = drive.DriveApi(googleAuthClient),
        _localFile = File(_localPath),
        _encrypt = encrypt,
        super(_localPath);

  @override
  Future<Meta> open([int version = 1]) async {
    var responseQuery = await _driveApi.files.list(q: "name='$_drivePath' and trashed = false");
    if (responseQuery.files.isNotEmpty) {
      _driveFileId = responseQuery.files[0].id;
      var driveFileContentStream = await _driveApi.files.get(_driveFileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      if (await _localFile.exists()) {
        await _localFile.delete();
      }
      await for (var value in driveFileContentStream.stream) {
        await _localFile.writeAsBytes(value, mode: FileMode.append, flush: true);
      }
      if (_encrypt) {
        // FIXME: Decrypt data after download!
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

  @override
  Future cleanup() async {
    await super.cleanup();
    await _uploadGoogleDrive();
  }

  Future<void> _uploadGoogleDrive() async {
    var driveFile = drive.File();
    driveFile.name = _drivePath;

    if (_encrypt) {
      // FIXME: Decrypt data before upload!
    }
    // Create a new back-up file on google drive.
    var uploadMedia =
        drive.Media(_localFile.openRead(), await _localFile.length());
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
