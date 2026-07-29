import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/models/app_user.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/common.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser user;
  final ThemeController themeController;
  final Future<void> Function() onSignOut;
  final Future<void> Function() onProfileChanged;
  const ProfileScreen({
    super.key,
    required this.user,
    required this.themeController,
    required this.onSignOut,
    required this.onProfileChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(title: 'Usuario', description: 'Datos personales, apariencia, notificaciones y seguridad.'),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: const BoxDecoration(gradient: NexoColors.brandGradient, shape: BoxShape.circle),
                  child: const Icon(Icons.person, size: 38, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.user.displayName, style: Theme.of(context).textTheme.titleLarge),
                      Text(widget.user.email, style: const TextStyle(color: NexoColors.muted)),
                      const SizedBox(height: 5),
                      Text('${widget.user.accountLabel} · ${widget.user.eventRoleLabel} · ${widget.user.classId}'),
                      Text('Código: ${widget.user.schoolCode}'),
                    ],
                  ),
                ),
                OutlinedButton.icon(onPressed: () => _editPersonalData(context), icon: const Icon(Icons.edit_outlined), label: const Text('Editar')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apariencia', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                DropdownButtonFormField<ThemeMode>(
                  initialValue: widget.themeController.mode,
                  decoration: const InputDecoration(labelText: 'Tema'),
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('Usar tema del sistema')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Claro')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Oscuro')),
                  ],
                  onChanged: (value) {
                    if (value != null) widget.themeController.setMode(value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: widget.themeController.palette,
                  decoration: const InputDecoration(labelText: 'Paleta de colores'),
                  items: const [
                    DropdownMenuItem(value: 'nexo', child: Text('NEXO 360')),
                    DropdownMenuItem(value: 'azul', child: Text('Azul Don Bosco')),
                    DropdownMenuItem(value: 'violeta', child: Text('Violeta')),
                    DropdownMenuItem(value: 'juventud', child: Text('Movimiento Juventud')),
                  ],
                  onChanged: (value) {
                    if (value != null) widget.themeController.setPalette(value);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                value: notifications,
                onChanged: (value) => setState(() => notifications = value),
                title: const Text('Recordatorios dentro de la aplicación'),
                subtitle: const Text('Muestra actividades próximas a vencer y avisos sin leer al abrir NEXO 360.'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(AppConfig.storageEnabled ? Icons.cloud_done_outlined : Icons.cloud_off_outlined),
                title: Text(AppConfig.storageEnabled ? 'Almacenamiento activo' : 'Almacenamiento en mantenimiento'),
                subtitle: const Text('En esta entrega las cargas de archivos se reemplazan temporalmente por enlaces externos.'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Página de descargas'),
                subtitle: const Text('APK de Android y paquete de Windows.'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => launchUrl(Uri.parse(AppConfig.downloadsPage), mode: LaunchMode.externalApplication),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('Seguridad'),
                subtitle: Text('La contraseña se administra mediante Firebase Authentication.'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(onPressed: widget.onSignOut, icon: const Icon(Icons.logout), label: const Text('Cerrar sesión')),
      ],
    );
  }

  Future<void> _editPersonalData(BuildContext context) async {
    final name = TextEditingController(text: widget.user.displayName);
    final phone = TextEditingController();
    final guardianPhone = TextEditingController();
    final address = TextEditingController();
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).get();
    phone.text = doc.data()?['phone'] as String? ?? '';
    guardianPhone.text = doc.data()?['guardianPhone'] as String? ?? '';
    address.text = doc.data()?['address'] as String? ?? '';
    if (!context.mounted) return;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar datos personales'),
        content: SizedBox(
          width: 620,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre completo')),
            const SizedBox(height: 10),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'Teléfono personal')),
            const SizedBox(height: 10),
            TextField(controller: guardianPhone, decoration: const InputDecoration(labelText: 'Teléfono del encargado')),
            const SizedBox(height: 10),
            TextField(controller: address, maxLines: 2, decoration: const InputDecoration(labelText: 'Dirección')),
          ]),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar'))],
      ),
    );
    if (saved != true) return;
    final batch = FirebaseFirestore.instance.batch();
    batch.update(FirebaseFirestore.instance.collection('users').doc(widget.user.uid), {
      'displayName': name.text.trim(),
      'phone': phone.text.trim(),
      'guardianPhone': guardianPhone.text.trim(),
      'address': address.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(FirebaseFirestore.instance.collection('directory_profiles').doc(widget.user.uid), {
      'displayName': name.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
    await widget.onProfileChanged();
    if (context.mounted) showMessage(context, 'Datos actualizados.');
  }
}
