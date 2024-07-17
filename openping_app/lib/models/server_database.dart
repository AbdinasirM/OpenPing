import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:openping_app/models/server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:provider/provider.dart'; //

class ServerDatabase extends ChangeNotifier {
  static late Isar isar;

  // Initialize the database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ServerSchema], directory: dir.path);
  }

  // List of current servers
  List<Server> currentServers = [];
  bool isLoading = false;

  // Fetch servers from the database
  Future<void> fetchServers() async {
    isLoading = true;
    notifyListeners();

    // Fetch all servers from the database
    List<Server> fetchedServers = await isar.servers.where().findAll();

    // Clear the current servers list
    currentServers.clear();

    for (var server in fetchedServers) {
      // Ping the server's IP address
      var ping = Ping(server.deviceIp, count: 1);
      var stream = ping.stream;

      try {
        await for (var event in stream) {
          if (event.summary != null) {
            var summary = event.summary!;
            bool isSuccess =
                (summary.transmitted != 0) == (summary.received != 0);
            server.status =
                isSuccess; // Update the server status based on ping result

            // Save the updated server status to the database
            await isar.writeTxn(() async {
              await isar.servers.put(server);
            });

            // Add the updated server to the current servers list
            currentServers.add(server);

            break; // Exit the loop once the result is obtained
          }
        }
      } catch (e) {
        print("Error occurred while pinging ${server.deviceIp}: $e");
      }
    }

    isLoading = false;
    // Notify listeners about the changes
    notifyListeners();
  }

  // Create a server and save to the db
  Future<void> addServer(String devicename, String deviceIp) async {
    isLoading = true;
    notifyListeners();

    print("Starting to add server: $devicename with IP: $deviceIp");

    var ping = Ping(deviceIp, count: 1);
    var stream = ping.stream;

    await for (var event in stream) {
      if (event.summary != null) {
        var summary = event.summary!;
        bool isSuccess = (summary.transmitted != 0) == (summary.received != 0);
        bool deviceStatus = isSuccess;

        final newServer = Server()
          ..deviceName = devicename
          ..deviceIp = deviceIp
          ..status = deviceStatus;

        await isar.writeTxn(() async {
          await isar.servers.put(newServer);
        });

        print("Server added successfully: $devicename with IP: $deviceIp");

        await fetchServers(); // Update the current servers
        notifyListeners();
        break; // Exit the loop once the result is obtained
      }
    }

    isLoading = false;
    notifyListeners();
  }

  // Update a server in db
  Future<void> updateServer(int id, String devicename, String deviceIp) async {
    isLoading = true;

    final existingServer = await isar.servers.get(id);
    var ping = Ping(deviceIp, count: 1);
    var stream = ping.stream;

    await for (var event in stream) {
      if (event.summary != null) {
        var summary = event.summary!;
        bool isSuccess = (summary.transmitted != 0) == (summary.received != 0);
        if (isSuccess) {
          if (existingServer != null) {
            existingServer.deviceName = devicename;
            existingServer.deviceIp = deviceIp;
            existingServer.status = true;

            // Save the new device name and device ip
            await isar.writeTxn(() => isar.servers.put(existingServer));

            // Update the current servers
            await fetchServers();

            notifyListeners();
          }
        } else {
          if (existingServer != null) {
            existingServer.deviceName = devicename;
            existingServer.deviceIp = deviceIp;
            existingServer.status = false;

            // Save the new device name and device ip
            await isar.writeTxn(() => isar.servers.put(existingServer));

            // Update the current servers
            await fetchServers();

            notifyListeners();
          }
        }
        break; // Exit the loop once the result is obtained
      }
    }

    isLoading = false;
    notifyListeners();
  }

  // Delete a server from db
  Future<void> deleteServer(int id) async {
    final existingServer = await isar.servers.get(id);
    if (existingServer != null) {
      // Delete the server
      await isar.writeTxn(() => isar.servers.delete(id));

      // Update the current servers
      await fetchServers();
      notifyListeners();
    }

    notifyListeners();
  }
}
