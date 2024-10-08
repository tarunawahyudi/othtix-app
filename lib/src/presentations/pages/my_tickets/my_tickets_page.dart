import 'package:othtix_app/src/blocs/tickets/my_ticket_purchases/my_ticket_purchases_bloc.dart';
import 'package:othtix_app/src/config/routes/route_names.dart';
import 'package:othtix_app/src/data/models/ticket/ticket_purchase_query.dart';
import 'package:othtix_app/src/data/models/ticket/ticket_purchase_status_enum.dart';
import 'package:othtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key, this.gotorefund = false});

  final bool gotorefund;

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage>
    with SingleTickerProviderStateMixin {
  static const double _filterChipsHeight = 50;

  late final MyTicketPurchasesBloc upcomingTicketPurchasesBloc,
      refundTicketPurchasesBloc;

  final _tabIndex = ValueNotifier(0);
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    upcomingTicketPurchasesBloc = GetIt.I<MyTicketPurchasesBloc>()
      ..add(const MyTicketPurchasesEvent.getMyTicketPurchases(
        TicketPurchaseQuery(
          status: TicketPurchaseStatus.completed,
        ),
      ));
    refundTicketPurchasesBloc = GetIt.I<MyTicketPurchasesBloc>()
      ..add(const MyTicketPurchasesEvent.getMyTicketPurchases(
        TicketPurchaseQuery(
          refundStatus: TicketPurchaseRefundStatus.refunding,
        ),
      ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gotorefund) {
      _tabIndex.value = 1;
      _tabController.animateTo(1);
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, innerBoxIsScrolled) => [
          SliverAppBar(
            centerTitle: true,
            pinned: true,
            floating: true,
            forceElevated: innerBoxIsScrolled,
            title: const Text('My Tickets'),
            actions: [
              IconButton(
                onPressed: () => context.goNamed(RouteNames.myTicketsHistory),
                icon: const FaIcon(FontAwesomeIcons.clockRotateLeft),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(
                kTextTabBarHeight + _filterChipsHeight,
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    onTap: (index) => _tabIndex.value = index,
                    tabs: const [
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Refund'),
                    ],
                  ),
                  SizedBox(
                    height: _filterChipsHeight,
                    child: ValueListenableBuilder(
                      valueListenable: _tabIndex,
                      builder: (_, index, __) {
                        switch (index) {
                          case 0:
                            return BlocProvider.value(
                              value: upcomingTicketPurchasesBloc,
                              child: const _FilterChips.upcoming(),
                            );
                          case 1:
                            return BlocProvider.value(
                              value: refundTicketPurchasesBloc,
                              child: const _FilterChips.refund(),
                            );
                          default:
                            return const SizedBox();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            BlocProvider.value(
              value: upcomingTicketPurchasesBloc,
              child: const TicketPurchaseList(),
            ),
            BlocProvider.value(
              value: refundTicketPurchasesBloc,
              child: const TicketPurchaseList(),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TicketPurchasesType { upcoming, refund }

class _FilterChips extends StatelessWidget {
  const _FilterChips.upcoming()
      : _purchasesType = _TicketPurchasesType.upcoming;
  const _FilterChips.refund() : _purchasesType = _TicketPurchasesType.refund;

  final _TicketPurchasesType _purchasesType;

  @override
  Widget build(BuildContext context) {
    TicketPurchaseQuery lastQuery = switch (_purchasesType) {
      _TicketPurchasesType.upcoming => const TicketPurchaseQuery(
          page: 0,
          status: TicketPurchaseStatus.completed,
        ),
      _TicketPurchasesType.refund => const TicketPurchaseQuery(
          page: 0,
          refundStatus: TicketPurchaseRefundStatus.refunding,
        ),
    };

    return BlocConsumer<MyTicketPurchasesBloc, MyTicketPurchasesState>(
      listener: (context, state) => state.mapOrNull(loaded: (state) async {
        if (state.exception != null) {
          return ErrorDialog.show(context, state.exception!);
        }
        return;
      }),
      builder: (context, state) {
        final bloc = context.read<MyTicketPurchasesBloc>();
        final loadedState = state.mapOrNull(loaded: (s) {
          lastQuery = s.query;
          return s;
        });
        final query = loadedState == null
            ? lastQuery
            : loadedState.query.copyWith(page: 0);

        return switch (_purchasesType) {
          _TicketPurchasesType.upcoming => _upcomingPurchasesFilterChips(
              query,
              bloc,
            ),
          _TicketPurchasesType.refund => _refundPurchasesFilterChips(
              query,
              bloc,
            ),
        };
      },
    );
  }

  Widget _upcomingPurchasesFilterChips(
    TicketPurchaseQuery query,
    MyTicketPurchasesBloc bloc,
  ) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      separatorBuilder: (_, __) => const SizedBox(width: 6),
      itemCount: TicketPurchaseStatus.values.length,
      itemBuilder: (_, index) {
        final filter = TicketPurchaseStatus.values[index];

        return FilterChip(
          selected: query.status == filter,
          onSelected: (s) {
            return bloc.add(MyTicketPurchasesEvent.getMyTicketPurchases(
              query.copyWith(status: s ? filter : null),
            ));
          },
          label: Text(filter.toString()),
        );
      },
    );
  }

  Widget _refundPurchasesFilterChips(
    TicketPurchaseQuery query,
    MyTicketPurchasesBloc bloc,
  ) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      separatorBuilder: (_, __) => const SizedBox(width: 6),
      itemCount: TicketPurchaseRefundStatus.values.length,
      itemBuilder: (_, index) {
        final filter = TicketPurchaseRefundStatus.values[index];

        return FilterChip(
          selected: query.refundStatus == filter,
          onSelected: (s) {
            return bloc.add(MyTicketPurchasesEvent.getMyTicketPurchases(
              query.copyWith(refundStatus: s ? filter : null),
            ));
          },
          label: Text(filter.toString()),
        );
      },
    );
  }
}
