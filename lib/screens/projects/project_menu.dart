import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../models/api/api.dart';
import '../../models/project_item.dart';
import '../../providers/apartment_provider.dart';
import '../../providers/projects_provider.dart';
import '../../utils/error_mapper.dart';

/// "⋮" on a project card: rename the project, manage its rooms, or delete it.
/// A project that only exists on this phone (never reached the server) can
/// only be deleted, and only locally.
class ProjectMenuButton extends ConsumerWidget {
  const ProjectMenuButton({required this.project, super.key});

  final ProjectItem project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      tooltip: l10n.projectMenuTooltip,
      icon: const Icon(Icons.more_vert),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      onPressed: () => _openMenu(context, ref),
    );
  }

  Future<void> _openMenu(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    List<Apartment>? flats;
    try {
      flats = await ref.read(apartmentsProvider.future);
    } catch (_) {
      // Unknown: treat it as a server project (never "delete locally only").
    }
    if (!context.mounted) return;
    final apartment = flats?.where((a) => a.id == project.id).firstOrNull;
    // Local-only only when the server list is known and lacks it.
    final localOnly = flats != null && apartment == null;
    final action = await showModalBottomSheet<_Action>(
      context: context,
      // Over the bottom bar, not under it.
      useRootNavigator: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!localOnly) ...[
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.projectRename),
                onTap: () => Navigator.of(sheet).pop(_Action.rename),
              ),
              if (apartment != null && apartment.rooms.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.meeting_room_outlined),
                  title: Text(l10n.projectRooms),
                  onTap: () => Navigator.of(sheet).pop(_Action.rooms),
                ),
            ],
            ListTile(
              leading: const Icon(Icons.delete_outline, color: DesignTokens.errorText),
              title: Text(l10n.projectDelete, style: const TextStyle(color: DesignTokens.errorText)),
              onTap: () => Navigator.of(sheet).pop(_Action.delete),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case _Action.rename:
        final name = await askName(context, title: l10n.projectRenameTitle, initial: project.name);
        if (name == null || !context.mounted) return;
        await _run(context, ref, () => ref.read(apartmentRepositoryProvider).updateApartment(project.id, name: name));
      case _Action.rooms:
        await showModalBottomSheet<void>(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          builder: (_) => _RoomsSheet(apartmentId: project.id),
        );
      case _Action.delete:
        final ok = await confirmDelete(
          context,
          title: l10n.projectDeleteTitle,
          body: l10n.projectDeleteBody(project.name, project.roomCount),
        );
        if (!ok || !context.mounted) return;
        if (localOnly) {
          ref.read(homeStateProvider.notifier).removeProject(project.id);
          return;
        }
        await _run(context, ref, () async {
          await ref.read(apartmentRepositoryProvider).deleteApartment(project.id);
          ref.read(homeStateProvider.notifier).removeProject(project.id);
        });
    }
  }
}

enum _Action { rename, rooms, delete }

/// Runs a server change, then reloads the projects; a failure is shown and
/// nothing on screen changes.
Future<void> _run(BuildContext context, WidgetRef ref, Future<void> Function() change) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await change();
    ref.invalidate(apartmentsProvider);
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(mapErrorToMessage(e))));
  }
}

/// A one-field name dialog; null when cancelled. Blank names can't be saved.
Future<String?> askName(BuildContext context, {required String title, required String initial}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _NameDialog(title: title, initial: initial),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, required this.initial});

  final String title;
  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _name => _controller.text.trim();

  void _save() {
    if (_name.isNotEmpty) Navigator.of(context).pop(_name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 100,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
        TextButton(onPressed: _name.isEmpty ? null : _save, child: Text(l10n.actionSave)),
      ],
    );
  }
}

/// "Can't be undone" confirmation; true only on an explicit "O'chirish".
Future<bool> confirmDelete(BuildContext context, {required String title, required String body}) async {
  final l10n = AppLocalizations.of(context)!;
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialog).pop(false), child: Text(l10n.actionCancel)),
        TextButton(
          onPressed: () => Navigator.of(dialog).pop(true),
          style: TextButton.styleFrom(foregroundColor: DesignTokens.errorText),
          child: Text(l10n.actionDelete),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// The project's rooms, each with rename and delete. Follows
/// [apartmentsProvider], so a change shows up as soon as it reloads.
class _RoomsSheet extends ConsumerWidget {
  const _RoomsSheet({required this.apartmentId});

  final String apartmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rooms = ref.watch(apartmentsProvider).valueOrNull
            ?.where((a) => a.id == apartmentId)
            .firstOrNull
            ?.rooms ??
        const <RoomOut>[];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: Text(l10n.projectRooms, style: DesignTokens.subtitle1),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final room in rooms)
                  ListTile(
                    leading: const Icon(Icons.meeting_room_outlined),
                    title: Text(room.name),
                    trailing: PopupMenuButton<_Action>(
                      tooltip: l10n.roomMenuTooltip(room.name),
                      onSelected: (a) => _onRoom(context, ref, room, a),
                      itemBuilder: (_) => [
                        PopupMenuItem(value: _Action.rename, child: Text(l10n.projectRename)),
                        PopupMenuItem(
                          value: _Action.delete,
                          child: Text(l10n.actionDelete, style: const TextStyle(color: DesignTokens.errorText)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRoom(BuildContext context, WidgetRef ref, RoomOut room, _Action action) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(apartmentRepositoryProvider);
    if (action == _Action.rename) {
      final name = await askName(context, title: l10n.roomRenameTitle, initial: room.name);
      if (name == null || !context.mounted) return;
      await _run(context, ref, () => repo.updateRoom(room.id, name: name));
    } else if (action == _Action.delete) {
      final ok = await confirmDelete(context, title: l10n.roomDeleteTitle, body: l10n.roomDeleteBody(room.name));
      if (!ok || !context.mounted) return;
      await _run(context, ref, () => repo.deleteRoom(room.id));
    }
  }
}
