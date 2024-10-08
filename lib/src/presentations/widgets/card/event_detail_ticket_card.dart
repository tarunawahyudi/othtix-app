import 'package:othtix_app/src/data/models/event/event_model.dart';
import 'package:othtix_app/src/data/models/ticket/ticket_model.dart';
import 'package:othtix_app/src/presentations/extensions/extensions.dart';
import 'package:othtix_app/src/presentations/utils/utils.dart';
import 'package:othtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class EventDetailTicketCard extends StatelessWidget {
  const EventDetailTicketCard({
    super.key,
    this.event,
    required this.ticket,
    this.onTap,
    this.onEdit,
  });

  final EventModel? event;
  final TicketModel ticket;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final dateStart = (ticket.salesOpenDate ?? event?.date) == null
        ? ''
        : DateFormat('dd/MM/yy')
            .format(ticket.salesOpenDate?.toLocal() ?? event!.date);
    final dateEnd = (ticket.purchaseDeadline ?? event?.endDate) == null
        ? ''
        : ' - ${DateFormat('dd/MM/yy').format(ticket.purchaseDeadline?.toLocal() ?? event!.endDate!)}';

    final dateText = '$dateStart$dateEnd';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.hardEdge,
            child: InkWelledStack(
              onTap: onTap,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.all(1),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.theme.disabledColor,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ticket.image == null
                          ? const Center(child: TicketImagePlaceholder())
                          : CustomNetworkImage(
                              src: ticket.image!,
                              small: true,
                              cached: false,
                            ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DefaultTextStyle.merge(
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    ticket.name,
                                    style:
                                        context.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    Utils.toSimpleCurrency(ticket.price),
                                    style:
                                        context.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: context.colorScheme.primary,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.calendarDay,
                                      size: 14,
                                      color: context.colorScheme.primary,
                                    ),
                                    if (onEdit == null) ...[
                                      const SizedBox(width: 4),
                                      const Text('Sales open'),
                                    ]
                                  ],
                                ),
                                Text(dateText),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.ticket,
                                        size: 14,
                                        color: context.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: MarqueeWidget(
                                          child: Text(
                                            'Available stock: ${ticket.currentStock}',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CustomBadge(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                    vertical: 1.5,
                                  ),
                                  borderColor: switch (ticket.status) {
                                    TicketStatus.notOpenedYet => Colors.orange,
                                    TicketStatus.available => Colors.green,
                                    _ => Colors.red,
                                  },
                                  child: Text(
                                    ticket.status.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: switch (ticket.status) {
                                        TicketStatus.notOpenedYet =>
                                          Colors.orange,
                                        TicketStatus.available => Colors.green,
                                        _ => Colors.red,
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (onEdit != null)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
            ),
          ),
      ],
    );
  }
}
