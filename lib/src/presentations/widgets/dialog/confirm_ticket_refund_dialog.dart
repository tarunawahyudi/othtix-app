import 'package:othtix_app/src/blocs/tickets/ticket_purchase_refund/ticket_purchase_refund_cubit.dart';
import 'package:othtix_app/src/data/models/ticket/ticket_purchase_model.dart';
import 'package:othtix_app/src/presentations/extensions/extensions.dart';
import 'package:othtix_app/src/presentations/utils/utils.dart';
import 'package:othtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class ConfirmTicketRefundDialog extends StatelessWidget {
  const ConfirmTicketRefundDialog({
    super.key,
    required this.ticketPurchase,
    required this.confirmText,
    required this.onConfirm,
    required this.titleText,
    required this.buttonText,
  });

  final TicketPurchaseModel ticketPurchase;
  final String confirmText;
  final String buttonText;
  final String titleText;
  final Future<void> Function(TicketPurchaseRefundCubit) onConfirm;

  static Future<bool?> show(
    BuildContext context, {
    required TicketPurchaseModel ticketPurchase,
    String titleText = 'Refund Confirmation',
    String confirmText = 'Are you sure you want to refund the ticket?',
    String buttonText = 'Confirm & Refund',
    required Future<void> Function(TicketPurchaseRefundCubit) onConfirm,
  }) async {
    return await showAdaptiveDialog<bool>(
      context: context,
      useSafeArea: true,
      builder: (_) {
        return BlocProvider(
          create: (_) => GetIt.I<TicketPurchaseRefundCubit>(),
          child: ConfirmTicketRefundDialog(
            ticketPurchase: ticketPurchase,
            confirmText: confirmText,
            titleText: titleText,
            onConfirm: onConfirm,
            buttonText: buttonText,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticket = ticketPurchase.ticket!;
    final event = ticketPurchase.ticket!.event!;

    return AlertDialog.adaptive(
      titleTextStyle: context.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      title: Text(titleText),
      content:
          BlocBuilder<TicketPurchaseRefundCubit, TicketPurchaseRefundState>(
        builder: (context, state) {
          return state.maybeMap(
            loading: (_) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitFadingFour(color: context.colorScheme.primary),
                const SizedBox(height: 12),
                const Text('Please wait...'),
              ],
            ),
            orElse: () {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text('Price'),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          Utils.toCurrency(ticket.price),
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colorScheme.primary,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(child: Text('User')),
                      Flexible(
                        child: Text(
                          '@${ticketPurchase.user?.username ?? 'Unknown'}',
                          maxLines: 1,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(child: Text('Purchase date')),
                      Expanded(
                        child: Text(
                          DateFormat('HH:mm:ss dd/MM/y')
                              .format(ticketPurchase.createdAt.toLocal()),
                          maxLines: 1,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('UID'),
                      const SizedBox(width: 16),
                      Flexible(
                        child: MarqueeWidget(
                          child: Text(ticketPurchase.uid, maxLines: 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Order ID'),
                      Text(ticketPurchase.orderId),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    confirmText,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.error,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      actions: [
        BlocBuilder<TicketPurchaseRefundCubit, TicketPurchaseRefundState>(
          builder: (context, state) {
            return FilledButton(
              onPressed: state.maybeMap(
                loading: (_) => null,
                orElse: () => () => Navigator.of(context).pop(false),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('Cancel'),
              ),
            );
          },
        ),
        BlocConsumer<TicketPurchaseRefundCubit, TicketPurchaseRefundState>(
          listener: (context, state) {
            state.mapOrNull(
              success: (_) => Navigator.of(context).pop(true),
            );
          },
          builder: (context, state) {
            return OutlinedButton(
              onPressed: state.maybeMap(
                loading: (_) => null,
                success: (_) => null,
                orElse: () => () async => await onConfirm(
                      context.read<TicketPurchaseRefundCubit>(),
                    ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colorScheme.error,
                side: BorderSide(color: context.colorScheme.error),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  state.maybeMap(
                    orElse: () => buttonText,
                    loading: (_) => 'Loading...',
                  ),
                  style: TextStyle(
                    color: context.colorScheme.error,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
