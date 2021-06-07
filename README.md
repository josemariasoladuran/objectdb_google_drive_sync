# ObjectDB embedded NoSQL Database auto-sync with Google Drive

## Introduction

Dart ObjectDB embedded NoSQL Database auto-sync with Google Drive personal account

## Motivation

Existing several apps that offer your the posibility of management your mensual expenses, with the goal that you can save your money. However, your private data is deposite in unknown cloud servers, and privacy is questioned because, at the very least the owner of this apps can see your economic data, something that it's very private.

ObjectDB Google Drive Sync, is a [ObjectDB](https://pub.dev/packages/objectdb/example)-based database, that it's use a Google Drive personal account storage, in order to save database in a cloud. This database will be cypher with a key calculate by the account of person authenticated in Google Drive.

In this way, any Flutter application can deal with sensitive user data, ensuring its durability, synchronizing said data in the cloud, and ensuring that said data belongs to the user, no one else will have access but the application itself and him. The developers of the apps that make use of ObjectDB Google Drive Sync, will not be able to manipulate the data, and the user who use a application in this situation, ensures the privacy of their sensitive data.

## Installation

```dart
dart pub add objectdb_google_drive_sync
```
## Usage

```dart

import 'package:http/http.dart' as http;
...
final http.Http googleAuthClient = /* Authenticated Http Client with Google Drive scope, personal Google account */;

final localPath = Directory.current.path + '/test.objectdb';
final db = GoogleDriveObjectDB(localPath, 'test.objectdb', googleAuthClient);
// insert document into database
await db.insert({
    'name': {'first': 'Bob', 'last': 'Last'},
    'age': 28,
    'active': true
});
await db.insert({
    'name': {'first': 'Alice', 'last': 'Last'},
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
var result = await db.find({'active': true, 'name.first': 'Bob'});

expect(result.isNotEmpty, equals(true));
// cleanup the db file
await db.cleanup();

// close db
await db.close();
```

For obtain _googleAuthClient_ value, you can use [googleapis_auth](https://pub.dev/packages/googleapis_auth)

```dart
Future test() async {
    ...
    var googleAuthClient = await clientViaUserConsent(
        ClientId(env['GOOGLE_TEST_APP_CLIENT_ID'], env['GOOGLE_TEST_APP_CLIENT_SECRET']),
        [drive.DriveApi.driveScope], (url) {
      print('Please go to the following URL and grant access:');
      print('  => $url"');
      print('');
    });

    ...
    ...
}
```

Also you can use [google_sign_in](https://pub.dev/packages/google_sign_in) in Flutter apps.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please makex sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/)
