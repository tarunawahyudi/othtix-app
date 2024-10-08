import 'package:othtix_app/src/data/models/event/event_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_model.freezed.dart';
part 'ticket_model.g.dart';

enum TicketStatus {
  notOpenedYet,
  available,
  soldOut,
  closed;

  @override
  String toString() => switch (this) {
        TicketStatus.notOpenedYet => 'Coming soon',
        TicketStatus.available => 'Available',
        TicketStatus.soldOut => 'Sold out',
        TicketStatus.closed => 'Closed',
      };
}

@freezed
class TicketModel with _$TicketModel {
  const TicketModel._();

  const factory TicketModel({
    required String id,
    required String name,
    required num price,
    required int stock,
    required int currentStock,
    String? image,
    DateTime? salesOpenDate,
    DateTime? purchaseDeadline,
    required DateTime createdAt,
    DateTime? updatedAt,
    EventModel? event,
  }) = _TicketModel;

  TicketStatus get status {
    if (salesOpenDate?.toLocal().isAfter(DateTime.now()) ?? false) {
      return TicketStatus.notOpenedYet;
    } else if (purchaseDeadline?.toLocal().isBefore(DateTime.now()) ?? false) {
      return TicketStatus.closed;
    } else if (currentStock <= 0) {
      return TicketStatus.soldOut;
    }
    return TicketStatus.available;
  }

  static TicketModel dummyTicket = TicketModel(
    id: '0',
    name: '-',
    price: 0,
    stock: 0,
    currentStock: 0,
    salesOpenDate: DateTime(2024),
    purchaseDeadline: DateTime(2024, 12, 31),
    createdAt: DateTime(2024),
  );

  factory TicketModel.fromJson(Map<String, dynamic> json) =>
      _$TicketModelFromJson(json);
}
