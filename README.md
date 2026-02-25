# Encrypted Core Data

Encrypted Core Data provides a Core Data store that encrypts all persisted data using SQLCipher. Aside from initial setup, usage is the same as standard Core Data and can replace the default SQLite store in existing projects.

## Requirements

- **iOS 12+** / **macOS 10.13+**
- Xcode project with Core Data enabled (or a `.xcdatamodeld` and `NSManagedObjectModel`)

## Setup

### Swift Package Manager

1. In Xcode: **File → Add Package Dependencies...**
2. Enter the package URL:  
   `https://github.com/RahulSV13/encrypted-core-data.git`
3. Choose **Up to Next Major Version** (or a specific version/tag).
4. Add the **EncryptedCoreData** library to your app target.

Or add to your own `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/RahulSV13/encrypted-core-data.git", from: "3.1.0"),
]
```

Then add `EncryptedCoreData` to your target’s dependencies.

### Import

**Objective-C:**

```objc
@import EncryptedCoreData;
// or
#import <EncryptedCoreData/EncryptedStore.h>
```

**Swift:**

```swift
import EncryptedCoreData
```

---

## Configuration

### Option keys

Use these keys in the options dictionary when creating the store:

| Key | Type | Description |
|-----|------|-------------|
| `EncryptedStorePassphraseKey` / `EncryptedStore.optionPassphraseKey` | `NSString` | **Required.** Passphrase used to encrypt/decrypt the database. |
| `EncryptedStoreDatabaseLocation` / `EncryptedStore.optionDatabaseLocation` | `NSURL` | Custom database file URL. Default: Application Support directory. |
| `EncryptedStoreCacheSize` / `EncryptedStore.optionCacheSize` | `NSNumber` | Custom SQLite cache size. |
| `EncryptedStore.optionFileManager` | `EncryptedStoreFileManager` | Custom file manager (e.g. for different bundle or paths). |
| `EncryptedStore.optionModelURL` | `NSURL` | URL for the Core Data model (`.momd`). |
| `EncryptedStore.optionDatabaseLocation` | `NSURL` | Override database file URL. |

### Basic setup (coordinator only)

Replace your existing persistent store coordinator setup with an encrypted store:

```objc
// Simple: model + passphrase
NSPersistentStoreCoordinator *coordinator = [EncryptedStore makeStore:[self managedObjectModel] passcode:@"YOUR_PASSCODE"];

// With options
NSDictionary *options = @{
    EncryptedStorePassphraseKey: @"YOUR_PASSCODE",
    EncryptedStoreCacheSize: @(5000),                    // optional
    EncryptedStoreDatabaseLocation: [self customDBURL]   // optional
};
NSPersistentStoreCoordinator *coordinator = [EncryptedStore makeStoreWithOptions:options
                                                              managedObjectModel:[self managedObjectModel]];
```

Use `makeStoreWithOptions:managedObjectModel:error:` if you need an `NSError **` for failure handling.

### Setup with NSPersistentContainer (recommended)

Use `NSPersistentStoreDescription` so the container loads an `EncryptedStore`:

```objc
NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:@[NSBundle.mainBundle]];
NSPersistentContainer *container = [[NSPersistentContainer alloc] initWithName:@"YourModelName" managedObjectModel:model];

NSDictionary *options = @{
    EncryptedStore.optionPassphraseKey : @"YOUR_PASSCODE",
    EncryptedStore.optionFileManager  : [EncryptedStoreFileManager defaultManager]  // optional
};

NSError *error = nil;
NSPersistentStoreDescription *description = [EncryptedStore makeDescriptionWithOptions:options
                                                                         configuration:nil
                                                                                 error:&error];
if (!description) {
    // handle error
    return;
}

container.persistentStoreDescriptions = @[description];

[container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *desc, NSError *err) {
    if (err) {
        NSLog(@"Encrypted store load error: %@", err);
        return;
    }
    // use container.viewContext, etc.
}];
```

### Optional: custom database location / bundle (EncryptedStoreFileManager)

To put the database in a specific bundle or control the file path:

```objc
EncryptedStoreFileManagerConfiguration *config = [EncryptedStoreFileManagerConfiguration new];
config.bundle = [NSBundle bundleWithIdentifier:@"com.example.database"];  // optional
config.databaseName = @"MyApp";           // optional, default derived from model
config.databaseExtension = @"sqlite";     // optional
// config.databaseURL = customURL;        // or set full URL

EncryptedStoreFileManager *fileManager = [[EncryptedStoreFileManager alloc] initWithConfiguration:config];

NSDictionary *options = @{
    EncryptedStore.optionPassphraseKey : @"YOUR_PASSCODE",
    EncryptedStore.optionFileManager   : fileManager
};
```

Then pass `options` into `makeStoreWithOptions:managedObjectModel:error:` or `makeDescriptionWithOptions:configuration:error:` as in the examples above.

### Changing the passphrase

After the store is loaded, you can change the passphrase (e.g. after user re-authentication):

```objc
EncryptedStore *store = (EncryptedStore *)coordinator.persistentStores.firstObject;
NSError *error = nil;
BOOL ok = [store checkAndChangeDatabasePassphrase:@"OLD_PASS" toNewPassphrase:@"NEW_PASS" error:&error];
```

---

## Using EncryptedStore

Use your `NSPersistentStoreCoordinator` or `NSPersistentContainer` as usual: create contexts, fetch requests, save. EncryptedStore is a drop-in replacement for `NSSQLiteStoreType`; only the setup differs.

**Debugging:** Add the launch argument `-com.apple.CoreData.SQLDebug 1` to log SQL statements (for development only).

---

## Security notes

- **Plain SQLite** keeps data in plain text (CWE-311: Missing Encryption of Sensitive Data).
- **Weak protection** (e.g. 4-digit passcode only) is inadequate (CWE-326, SRG-APP-000129). Use a strong passphrase and secure storage (e.g. Keychain) for the passphrase in production.

---

## Features

- One-to-one, one-to-many, and many-to-many relationships
- Predicates and inherited entities
- Same Core Data API as the default SQLite store

Known issues and feature requests: [issue tracker](https://github.com/RahulSV13/encrypted-core-data/issues).

---

## Diagram

Comparison between `NSSQLiteStore` and EncryptedStore:

![Architecture](diagram.jpg)

## Strings comparison

Default Core Data SQLite leaves data in plain text; EncryptedStore encrypts the file:

![Strings output](stringOutput.jpg)

---

## License

Copyright 2012–2014 The MITRE Corporation. Licensed under the Apache License, Version 2.0.  
See the [LICENSE](LICENSE) file for details.
