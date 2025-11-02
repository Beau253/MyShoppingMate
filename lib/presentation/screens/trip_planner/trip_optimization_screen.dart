import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_shopping_mate/bloc/trip_plan/trip_plan_bloc.dart';
import 'package:my_shopping_mate/data/models/trip_plan_model.dart';
import 'package:my_shopping_mate/data/repositories/trip_plan_repository.dart';
import 'package:my_shopping_mate/presentation/screens/trip_planner/shopping_mode_screen.dart';
import 'package:my_shopping_mate/presentation/widgets/atoms/PrimaryButton.dart';
import 'package:my_shopping_mate/presentation/widgets/molecules/trip_item_card.dart';

class TripOptimizationScreen extends StatelessWidget {
  final String listId; // Requires the list ID to fetch the plan

  const TripOptimizationScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripPlanBloc(tripPlanRepository: FakeTripPlanRepository())
        ..add(TripPlanLoaded(listId)),
      child: const TripOptimizationView(),
    );
  }
}

class TripOptimizationView extends StatefulWidget {
  const TripOptimizationView({super.key});

  @override
  State<TripOptimizationView> createState() => _TripOptimizationViewState();
}

class _TripOptimizationViewState extends State<TripOptimizationView> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Plan'),
      ),
      body: BlocBuilder<TripPlanBloc, TripPlanState>(
        builder: (context, state) {
          if (state.status == TripPlanStatus.loading || state.status == TripPlanStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == TripPlanStatus.failure || state.tripPlan == null) {
            return const Center(child: Text('Failed to generate trip plan.'));
          }

          final tripPlan = state.tripPlan!;
          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: tripPlan.stores.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final storeData = tripPlan.stores[index];
                    return _buildStoreColumn(context, storeData);
                  },
                ),
              ),
              _buildPageIndicator(context, tripPlan.stores.length),
              _buildFooter(context, tripPlan),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStoreColumn(BuildContext context, TripStore storeData) {
    final storeName = storeData.storeName;
    final items = storeData.items;
    final storeTotal = items.fold(0.0, (sum, item) => sum + (item.item.price * item.item.quantity));
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(storeName, style: Theme.of(context).textTheme.headline1),
              Text(currencyFormatter.format(storeTotal), style: Theme.of(context).textTheme.headline2),
            ],
          ),
          const Divider(height: 24),
          if (items.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('No items for this store.')))
          else
            ...items.map((tripItem) {
              final alternativeStore = context.read<TripPlanBloc>().state.tripPlan?.stores.firstWhere(
                (store) => store.storeId == tripItem.alternativeStoreId
              );
              final alternative = alternativeStore != null
                  ? AlternativePrice(storeName: alternativeStore.storeName, price: tripItem.alternativePrice)
                  : null;

              return TripItemCard(
                productName: tripItem.item.productName,
                currentPrice: tripItem.item.price,
                quantity: tripItem.item.quantity,
                alternative: alternative,
                onMove: (toStore) {
                  context.read<TripPlanBloc>().add(TripItemMoved(tripItem));
                },
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(BuildContext context, int pageCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPageIndex == index
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.5),
          ),
        );
      }),
    );
  }

  Widget _buildFooter(BuildContext context, TripPlan tripPlan) {
    final grandTotal = tripPlan.stores.fold(0.0, (sum, store) => sum + store.items.fold(0.0, (sum, item) => sum + (item.item.price * item.item.quantity)));
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      child: Padding(
        padding: const EdgeInsets.all(16.0).copyWith(bottom: 24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Grand Total', style: Theme.of(context).textTheme.headline2),
                Text(currencyFormatter.format(grandTotal), style: Theme.of(context).textTheme.headline2?.copyWith(color: Theme.of(context).primaryColor)),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Finalize & Go Shopping',
              onPressed: () {
                if (tripPlan.stores.isNotEmpty) {
                  final firstStore = tripPlan.stores[0];
                  // Pass the final, potentially modified, item list to the shopping screen.
                  final itemsForShopping = firstStore.items.map((tripItem) => tripItem.item).toList();

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ShoppingModeScreen(
                        storeName: firstStore.storeName,
                        items: itemsForShopping,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}