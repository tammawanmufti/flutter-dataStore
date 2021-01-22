import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'model.dart';

class DataStore {
  String storeName;
  DataStore(this.storeName) {
    _init();
  }

  void _init() async {
    // File store = await _storeFile();
    // store.writeAsStringSync('[]', mode: FileMode.write);
  }

  Future<File> _storeFile() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory _dsDir = Directory('${appDir.path}/DataStore/');
    if (await _dsDir.exists()) {
      print('$storeName is exist');
      return File("${_dsDir.path}/$storeName.store");
    } else {
      final Directory _dsDirNew = await _dsDir.create(recursive: true);
      print('$storeName is Created');
      return File("${_dsDirNew.path}/$storeName.store");
    }
  }

  Future<List<Store>> findAll() async {
    print('findAll');
    File store = await _storeFile();
    final data = jsonDecode(await store.readAsString());
    List<Store> result = data.map<Store>((e) => Store.fromMap(e)).toList();
    print("findAll :${result.length}");
    return result;
  }

  Future<Store> findById(int id) async {
    final List<Store> stores = await findAll();
    Store data = stores.firstWhere((element) => element.id == id);
    if (data != null) {
      if (data.isDeleted == 0) return data;
    }
    return null;
  }

  Future<bool> delete(id, {softDelete = true}) async {
    try {
      File store = await _storeFile();
      List<Store> tempStores = await findAll();
      Store deletedData = await findById(id);
      tempStores.removeWhere((element) => element.id == deletedData.id);
      if (softDelete) {
        deletedData.isDeleted = 1;
        tempStores.add(deletedData);
      }
      print(tempStores.length);
      tempStores.sort((a, b) => b.id.compareTo(a.id));
      store.writeAsStringSync(
          jsonEncode(tempStores.map((e) => e.toMap()).toList()),
          mode: FileMode.write);
      _Console.log('$id deleted');
      return true;
    } catch (e) {
      _Console.log('failed to deleting data');
      _Console.log('$e');
      return false;
    }
  }

  Future<bool> add(Map map) async {
    try {
      File store = await _storeFile();
      File conf = File('${store.path}.ds');
      if (store.existsSync()) {
        int id = int.parse(conf.readAsStringSync()) + 1;
        List read = jsonDecode(store.readAsStringSync());
        List<Store> tempStore = read
            .map<Store>((e) => Store.fromMap(e))
            .toList()
              ..add(Store(id, map));
        tempStore.sort((a, b) => b.id.compareTo(a.id));
        store.writeAsStringSync(
            jsonEncode(tempStore.map((e) => e.toMap()).toList()),
            mode: FileMode.write);
        conf.writeAsStringSync('$id', mode: FileMode.write);
      } else {
        store.writeAsStringSync(jsonEncode([Store(0, map).toMap()]),
            mode: FileMode.write);
        conf.writeAsStringSync('0', mode: FileMode.write);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteStoreDestructive() async {
    ///remove dataStore [warning destructive]
    File store = await _storeFile();
    store.deleteSync();
  }

  static Future<void> init() async {
    _Console.log('Initializing...');
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      _Console.log('Looking for DataChest...');
      final directoryApp = Directory('${directory.path}/DataStore/');
      if (!await directoryApp.exists()) {
        directoryApp.create(recursive: true);
        _Console.log('DataChest Created!');
      } else {
        _Console.log('DataChest Found!');
      }
      _Console.log('Initialize Completed');
    } catch (error) {
      _Console.log('Initialize Failed');
      _Console.log(": Error : $error");
    }
  }

  static Future<List<FileSystemEntity>> readChest() async {
    String directory = (await getApplicationDocumentsDirectory()).path;
    List file = Directory("$directory/DataStore/").listSync();
    return file;
  }
}

class _Console {
  static void log(String message) {
    print("DataStore: $message");
  }
}
