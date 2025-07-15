import 'package:flutter/material.dart';
import 'dart:io';
import '../services/supabase_service.dart';
import '../services/image_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _visitors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVisitors();
  }

  Future<void> _loadVisitors() async {
    final visitors = await SupabaseService().getVisitors();
    setState(() {
      _visitors = visitors;
      _loading = false;
    });
  }

  void _logout() async {
    await SupabaseService().logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void _showAddVisitorDialog() async {
    String name = '';
    String reason = '';
    DateTime? timestamp = DateTime.now();
    String? photoPath;
    String? photoUrl;
    final formKey = GlobalKey<FormState>();
    bool isUploading = false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Registrar visitante'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Nombre'),
                        validator: (v) => v == null || v.isEmpty ? 'Ingrese el nombre' : null,
                        onChanged: (v) => name = v,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Motivo de la visita'),
                        validator: (v) => v == null || v.isEmpty ? 'Ingrese el motivo' : null,
                        onChanged: (v) => reason = v,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Hora: '),
                          TextButton(
                            child: Text(timestamp != null ? '${timestamp?.hour ?? ''}:${timestamp?.minute ?? ''}' : 'Seleccionar'),
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(timestamp ?? DateTime.now()),
                              );
                              if (picked != null) {
                                setState(() {
                                  timestamp = DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    DateTime.now().day,
                                    picked.hour,
                                    picked.minute,
                                  );
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (isUploading)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                      else if (photoUrl == null)
                        ElevatedButton.icon(
                          icon: Icon(Icons.camera_alt),
                          label: Text('Tomar foto'),
                          onPressed: () async {
                            final path = await ImageService.pickImage();
                            if (path != null) {
                              setState(() => isUploading = true);
                              // Let the UI update before starting the upload
                              await Future.delayed(Duration(milliseconds: 100));
                              final url = await ImageService.uploadVisitorImage(path);
                              setState(() {
                                photoPath = path;
                                photoUrl = url;
                                isUploading = false;
                              });
                            }
                          },
                        )
                      else
                        Column(
                          children: [
                            Image.network(
                              photoUrl!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            TextButton(
                              child: Text('Cambiar foto'),
                              onPressed: () async {
                                final path = await ImageService.pickImage();
                                if (path != null) {
                                  setState(() => isUploading = true);
                                  // Let the UI update before starting the upload
                                  await Future.delayed(Duration(milliseconds: 100));
                                  final url = await ImageService.uploadVisitorImage(path);
                                  setState(() {
                                    photoPath = path;
                                    photoUrl = url;
                                    isUploading = false;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: isUploading ? null : () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isUploading
                  ? null
                  : () async {
                      if (formKey.currentState?.validate() != true) return;
                      if (photoUrl == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Por favor, toma y sube una foto del visitante.')),
                        );
                        return;
                      }
                      await SupabaseService().addVisitor(
                        name: name,
                        reason: reason,
                        timestamp: timestamp ?? DateTime.now(),
                        photoUrl: photoUrl!,
                      );
                      Navigator.of(context).pop();
                      _loadVisitors();
                    },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(
        title: Text('Visitantes registrados'),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: _logout, tooltip: 'Cerrar sesión'),
        ],
      ),
      body: _visitors.isEmpty
          ? Center(
              child: Text(
                'No hay visitantes registrados.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _visitors.length,
              itemBuilder: (context, idx) {
                final visitor = _visitors[idx];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: visitor['photo_url'] != null
                        ? CircleAvatar(backgroundImage: NetworkImage(visitor['photo_url']))
                        : CircleAvatar(child: Icon(Icons.person)),
                    title: Text(visitor['name'] ?? ''),
                    subtitle: Text('${visitor['reason'] ?? ''}\n${visitor['timestamp'] != null ? DateTime.parse(visitor['timestamp']).toLocal().toString().substring(0, 16) : ''}'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Agregar nuevo visitante',
        onPressed: _showAddVisitorDialog,
      ),
    );
  }
}
