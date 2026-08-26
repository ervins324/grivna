import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../accounts/providers/account_providers.dart';
import '../providers/subscription_providers.dart';
import 'widgets/add_subscription_sheet.dart';
import 'widgets/future_cost_calculator.dart';
import 'widgets/subscription_card.dart';
import 'widgets/upcoming_timeline_widget.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subsAsync = ref.watch(subscriptionsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Text('Subscriptions', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            tooltip: 'Add Subscription',
            onPressed: () => AddSubscriptionSheet.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Future Cost Projection Interactive Calculator
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: FutureCostCalculator(),
            ),

            const SizedBox(height: 20),

            // Upcoming Reminders Timeline
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: UpcomingTimelineWidget(),
            ),

            const SizedBox(height: 20),

            // Active Subscriptions List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ACTIVE SUBSCRIPTIONS',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  subsAsync.when(
                    data: (subs) => Text(
                      '${subs.where((s) => s.isActive).length} active • Swipe to delete',
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            subsAsync.when(
              data: (subs) {
                if (subs.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.subscriptions_outlined, size: 36, color: AppColors.textTertiary),
                          const SizedBox(height: 10),
                          Text('No subscriptions added', style: AppTypography.bodyMedium),
                          const SizedBox(height: 4),
                          Text('Tap + to track Netflix, Spotify, iCloud, etc.', style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: subs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final sub = subs[index];
                    return Dismissible(
                      key: Key('sub_${sub.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: AppColors.negative,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Delete',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.delete_outline, color: Colors.white, size: 22),
                          ],
                        ),
                      ),
                      onDismissed: (_) {
                        ref.read(accountRepositoryProvider).deleteSubscription(sub.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Deleted subscription: ${sub.name}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: SubscriptionCard(subscription: sub),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
                ),
              ),
              error: (e, _) => Center(
                child: Text('Error loading subscriptions', style: TextStyle(color: AppColors.negative)),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
