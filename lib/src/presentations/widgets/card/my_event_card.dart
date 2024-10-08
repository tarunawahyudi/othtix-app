import 'package:othtix_app/src/data/models/event/event_model.dart';
import 'package:othtix_app/src/data/models/event/event_status_enum.dart';
import 'package:othtix_app/src/presentations/extensions/extensions.dart';
import 'package:othtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class MyEventCard extends StatelessWidget {
  const MyEventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.heroImageTag,
  });

  const factory MyEventCard.small({
    required EventModel event,
    VoidCallback onTap,
  }) = _SmallEventCard;

  final EventModel event;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Object? heroImageTag;

  @override
  Widget build(BuildContext context) {
    final dateStart = DateFormat('dd/MM/y').format(event.date.toLocal());
    final dateEnd = event.endDate == null
        ? ''
        : ' - ${DateFormat('dd/MM/y').format(event.endDate!.toLocal())}';

    final dateText = '$dateStart$dateEnd';

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            constraints: const BoxConstraints(minHeight: 120),
            child: InkWelledStack(
              onTap: onTap,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.all(1),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.theme.disabledColor,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: event.images.isEmpty
                          ? const EventImagePlaceholder()
                          : Hero(
                              tag: heroImageTag ?? event.id,
                              child: CustomNetworkImage(
                                src: event.images[0].image,
                                small: true,
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.name,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: event.isEnded
                                  ? context.theme.disabledColor
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.calendarDay,
                                size: 18,
                                color: event.isEnded
                                    ? context.theme.disabledColor
                                    : context.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dateText,
                                style: TextStyle(
                                  color: event.isEnded
                                      ? context.theme.disabledColor
                                      : null,
                                ),
                              ),
                              if (event.endDate == null) ...[
                                const SizedBox(width: 8),
                                FaIcon(
                                  FontAwesomeIcons.clock,
                                  size: 18,
                                  color: event.isEnded
                                      ? context.theme.disabledColor
                                      : context.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat.Hm().format(event.date.toLocal()),
                                  style: TextStyle(
                                    color: event.isEnded
                                        ? context.theme.disabledColor
                                        : null,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Text('Status'),
                              const SizedBox(width: 4),
                              _StatusBadge(event: event),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.locationDot,
                                size: 18,
                                color: event.isEnded
                                    ? context.theme.disabledColor
                                    : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  event.location,
                                  style: TextStyle(
                                    color: event.isEnded
                                        ? context.theme.disabledColor
                                        : null,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        PopupMenuButton(
          itemBuilder: (_) => [
            PopupMenuItem(
              onTap: onEdit,
              child: const ListTile(
                title: Text('Edit'),
                trailing: Icon(Icons.edit),
              ),
            ),
            if (event.status != EventStatus.published)
              PopupMenuItem(
                onTap: onDelete,
                child: ListTile(
                  title: const Text('Delete'),
                  trailing: const Icon(Icons.delete_forever),
                  textColor: context.colorScheme.error,
                  iconColor: context.colorScheme.error,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SmallEventCard extends MyEventCard {
  const _SmallEventCard({required super.event, super.onTap});

  @override
  Widget build(BuildContext context) {
    final dateStart = DateFormat('dd/MM/yy HH:mm').format(event.date.toLocal());
    final dateEnd = event.endDate == null
        ? ''
        : ' - ${DateFormat('dd/MM/yy HH:mm').format(event.endDate!.toLocal())}';

    final dateText = '$dateStart$dateEnd';

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      constraints: const BoxConstraints(minHeight: 80),
      child: InkWelledStack(
        onTap: onTap,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                width: 80,
                margin: const EdgeInsets.all(1),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.theme.disabledColor,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: event.images.isEmpty
                    ? const EventImagePlaceholder()
                    : Hero(
                        tag: heroImageTag ?? event.id,
                        child: CustomNetworkImage(
                          src: event.images[0].image,
                          small: true,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            event.name,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: event.isEnded
                                  ? context.theme.disabledColor
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _StatusBadge(event: event),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.calendarDay,
                          size: 18,
                          color: event.isEnded
                              ? context.theme.disabledColor
                              : context.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateText,
                          style: TextStyle(
                            color: event.isEnded
                                ? context.theme.disabledColor
                                : null,
                          ),
                        ),
                        if (event.endDate == null) ...[
                          const SizedBox(width: 8),
                          FaIcon(
                            FontAwesomeIcons.clock,
                            size: 18,
                            color: event.isEnded
                                ? context.theme.disabledColor
                                : context.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat.Hm().format(event.date.toLocal()),
                            style: TextStyle(
                              color: event.isEnded
                                  ? context.theme.disabledColor
                                  : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.locationDot,
                          size: 18,
                          color: event.isEnded
                              ? context.theme.disabledColor
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              color: event.isEnded
                                  ? context.theme.disabledColor
                                  : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final String text = event.isEnded
        ? 'Ended'
        : event.isOnGoing || event.status != EventStatus.published
            ? event.status.toString()
            : 'Not Started';

    return CustomBadge(
      borderColor: getColor(context.isDark),
      child: Text(
        text,
        style: context.textTheme.labelSmall?.copyWith(
          color: getColor(context.isDark),
        ),
      ),
    );
  }

  Color getColor(bool isDark) {
    final color = event.isEnded
        ? Colors.red
        : event.isOnGoing || event.status != EventStatus.published
            ? switch (event.status) {
                EventStatus.draft => Colors.orange,
                EventStatus.published => Colors.green,
                EventStatus.cancelled => Colors.red,
                EventStatus.rejected => Colors.red,
              }
            : Colors.orange;

    final colorDarkTheme = event.isEnded
        ? Colors.redAccent
        : event.isOnGoing || event.status != EventStatus.published
            ? switch (event.status) {
                EventStatus.draft => Colors.orangeAccent,
                EventStatus.published => Colors.greenAccent,
                EventStatus.cancelled => Colors.redAccent,
                EventStatus.rejected => Colors.redAccent,
              }
            : Colors.orangeAccent;

    return isDark ? colorDarkTheme : color;
  }
}
