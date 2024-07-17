import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:openping_app/models/server.dart';
import 'package:openping_app/models/server_database.dart';

class ServersPage extends StatefulWidget {
  const ServersPage({Key? key}) : super(key: key);

  @override
  State<ServersPage> createState() => _ServersPageState();
}

class _ServersPageState extends State<ServersPage> {
  final TextEditingController devicenameController = TextEditingController();
  final TextEditingController deviceipController = TextEditingController();
  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    // Fetch servers when page initializes
    _fetchServers();
  }

  @override
  void dispose() {
    devicenameController.dispose();
    deviceipController.dispose();
    super.dispose();
  }

  void _fetchServers() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });
    try {
      await context.read<ServerDatabase>().fetchServers();
    } catch (e) {
      print('Error fetching servers: $e');
      // Handle error if needed
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false after operation
      });
    }
  }

  void createServer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                TextField(
                  controller: devicenameController,
                  decoration: InputDecoration(
                    labelText: 'Device Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: deviceipController,
                  decoration: InputDecoration(
                    labelText: 'Device IP',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 150.0, // Set the desired width here
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(Color.fromARGB(255, 0, 0, 0)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
                onPressed: () {
                  // Add server to database
                  context.read<ServerDatabase>().addServer(
                        devicenameController.text,
                        deviceipController.text,
                      );

                  // Clear text field controllers
                  devicenameController.clear();
                  deviceipController.clear();

                  // Dismiss dialog
                  Navigator.pop(context);
                },
                child: Center(
                    child: Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void updateServer(BuildContext context, Server server) {
    devicenameController.text = server.deviceName;
    deviceipController.text = server.deviceIp;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                TextField(
                  controller: devicenameController,
                  decoration: InputDecoration(
                    labelText: 'Device Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: deviceipController,
                  decoration: InputDecoration(
                    labelText: 'Device IP',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 150.0, // Set the desired width here
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(Color.fromARGB(255, 0, 0, 0)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      side: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
                onPressed: () {
                  // Add server to database
                  context.read<ServerDatabase>().updateServer(
                        server.id,
                        devicenameController.text,
                        deviceipController.text,
                      );

                  // Clear text field controllers
                  devicenameController.clear();
                  deviceipController.clear();

                  // Dismiss dialog
                  Navigator.pop(context);
                },
                child: Center(
                    child: Text(
                  "Update",
                  style: TextStyle(color: Colors.white),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void deleteServer(BuildContext context, int id) {
    context.read<ServerDatabase>().deleteServer(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: Colors.white,
        title: Center(
          child: Text('Devices'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createServer(context),
        backgroundColor: Colors.white,
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      body: Stack(
        children: [
          Consumer<ServerDatabase>(
            builder: (context, serverDatabase, child) {
              List<Server> currentServers = serverDatabase.currentServers;
              return ListView.builder(
                itemCount: currentServers.length,
                itemBuilder: (context, index) {
                  final server = currentServers[index];
                  final containerColor = server.status
                      ? Colors.green
                      : Colors.red; // Assuming status is a boolean
                  final containerBorderColor = server.status
                      ? Colors.green
                      : Colors.red; // Adjust as per your UI needs
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                            width: 2,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: containerColor,
                                    border: Border.all(
                                      width: 4,
                                      color: containerBorderColor,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      server.deviceName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      server.deviceIp,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => updateServer(context, server),
                                icon: Icon(Icons.edit, color: Colors.white),
                              ),
                              IconButton(
                                onPressed: () =>
                                    deleteServer(context, server.id),
                                icon: Icon(Icons.delete, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                     
                    ),
                  );
                },
              );
            },
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      const Color.fromARGB(255, 238, 238, 238)),
                  strokeWidth: 6),
            ),
        ],
      ),
    );
  }
}
