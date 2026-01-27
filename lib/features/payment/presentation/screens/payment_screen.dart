import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_container.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';

import 'package:whos_got_what/features/profile/data/profile_providers.dart';
import 'package:whos_got_what/features/profile/data/profile_repository.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _loading = true;
  bool _restoreInProgress = false;
  int _restoredCount = 0;
  Timer? _restoreSummaryTimer;

  static const _productIds = {
    'SINGLE_EVENT_CREDIT',
    'Pro_User',
    'UNLIMITED_TIER',
  };

  @override
  void initState() {
    super.initState();
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      (purchaseList) => _listenToPurchaseUpdated(purchaseList),
      onDone: () => _subscription.cancel(),
      onError: (error) => debugPrint('IAP error: $error'),
    );
    _initStoreInfo();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _restoreSummaryTimer?.cancel();
    super.dispose();
  }

  Future<void> _initStoreInfo() async {
    final bool isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final ProductDetailsResponse response = await _iap.queryProductDetails(
      _productIds,
    );
    if (response.error != null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    if (mounted) {
      setState(() {
        _products = response.productDetails;
        _loading = false;
      });
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseList) {
    for (final purchase in purchaseList) {
      debugPrint(
        'IAP update: ${purchase.productID} status=${purchase.status} '
        'pendingComplete=${purchase.pendingCompletePurchase}',
      );
      if (purchase.status == PurchaseStatus.pending) {
        debugPrint('IAP pending: ${purchase.productID}');
      } else {
        if (purchase.status == PurchaseStatus.error) {
          _handleError(purchase.error!);
        } else if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          _verifyPurchase(purchase);

          if (purchase.status == PurchaseStatus.restored &&
              _restoreInProgress) {
            _restoredCount += 1;
            _scheduleRestoreSummary();
          }
        }
        if (purchase.pendingCompletePurchase) {
          _iap.completePurchase(purchase);
        }
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.functions.invoke(
        'verify-purchase',
        body: {
          'productId': purchase.productID,
          'purchaseToken': purchase.purchaseID ?? purchase.verificationData.serverVerificationData,
          'status': purchase.status.name,
          'payload': purchase.verificationData.localVerificationData,
        },
      );

      if (response.status != 200) {
        throw Exception('Backend verification failed: ${response.data}');
      }

      // Refresh profile to reflect backend changes
      await ref.read(profileControllerProvider.notifier).reload();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase verified! Thank you for your support.'),
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      debugPrint('Verification error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e')),
        );
      }
    }
  }

  void _handleError(IAPError error) {
    debugPrint('IAP error: ${error.code} ${error.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failure: ${error.message}')),
    );
  }

  Future<void> _restorePurchases() async {
    try {
      _restoreInProgress = true;
      _restoredCount = 0;
      _scheduleRestoreSummary();
      await _iap.restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Restore started...')));
      }
    } catch (e) {
      debugPrint('Restore purchases failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restore failed. Try again.')),
        );
      }
    }
  }

  void _scheduleRestoreSummary() {
    _restoreSummaryTimer?.cancel();
    _restoreSummaryTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      final count = _restoredCount;
      final message = count == 0
          ? 'No previous purchases found.'
          : 'Restored $count purchase${count == 1 ? '' : 's'}.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      _restoreInProgress = false;
      _restoredCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppTheme.buildBackground(
      context: context,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Upgrade Account'),
          backgroundColor: Colors.transparent,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Choose a plan that works for you",
                      style: AppTextStyles.headlinePrimary(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Unlock premium features and post more events",
                      style: AppTextStyles.body(context).copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    ..._buildPlanCards(theme),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Maybe Later'),
                    ),
                    TextButton(
                      onPressed: _restorePurchases,
                      child: const Text('Restore Purchases'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _buildPlanCards(ThemeData theme) {
    // Define the 3 core plans
    final plans = [
      {
        'id': 'SINGLE_EVENT_CREDIT',
        'title': 'Single Event Credit',
        'price': '\$4.99',
        'period': 'one-time',
        'secondary': true,
      },
      {
        'id': 'Pro_User',
        'title': 'Pro Subscriber',
        'price': '\$14.99',
        'period': 'per month',
        'secondary': false,
      },
      {
        'id': 'UNLIMITED_TIER',
        'title': 'Unlimited Pass',
        'price': '\$24.99',
        'period': 'per month',
        'secondary': true,
      },
    ];

    return plans.map((plan) {
      final productId = plan['id'] as String;
      // Try to find the actual IAP product for price/details if available
      final product = _products.any((p) => p.id == productId)
          ? _products.firstWhere((p) => p.id == productId)
          : null;

      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: _PaymentCard(
          title: plan['title'] as String,
          price: product?.price ?? plan['price'] as String,
          period: plan['period'] as String,
          features: _getFeaturesFor(productId),
          buttonText: product != null ? 'Purchase' : 'Loading...',
          secondary: plan['secondary'] as bool,
          onPressed: product != null
              ? () {
                  final isSubscription = productId == 'Pro_User' || productId == 'UNLIMITED_TIER';
                  final PurchaseParam purchaseParam = PurchaseParam(
                    productDetails: product,
                  );
                  if (isSubscription) {
                    _iap.buyNonConsumable(purchaseParam: purchaseParam);
                  } else {
                    _iap.buyConsumable(purchaseParam: purchaseParam);
                  }
                }
              : null, // Disable if store product not found yet
        ),
      );
    }).toList();
  }

  List<String> _getFeaturesFor(String productId) {
    if (productId == 'Pro_User') {
      return [
        'Up to 3 concurrent active events',
        'Slots renew as events end',
        'Custom business profile',
        'Priority support',
      ];
    } else if (productId == 'UNLIMITED_TIER') {
      return [
        'Unlimited concurrent active events',
        'Full platform access',
        'Advanced analytics',
        'Featured placement',
      ];
    } else if (productId == 'SINGLE_EVENT_CREDIT') {
      return [
        'Post 1 event credit',
        'No monthly commitment',
        'Credits never expire',
      ];
    } else {
      return [
        'Post 1 event credit',
        'No monthly commitment',
        'Credits never expire',
      ];
    }
  }
}

class _PaymentCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final String buttonText;
  final bool secondary;
  final VoidCallback? onPressed;

  const _PaymentCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.buttonText,
    this.secondary = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Override pricing display if needed to match hard requirements exactly
    String displayPrice = price;
    if (title.contains('Pro')) displayPrice = '\$14.99';
    if (title.contains('Unlimited')) displayPrice = '\$24.99';
    if (title.contains('Credit')) displayPrice = '\$4.99';

    return NeumorphicContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleLarge(context)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                displayPrice,
                style: AppTextStyles.headlinePrimary(
                  context,
                ).copyWith(color: secondary ? null : theme.colorScheme.primary),
              ),
              const SizedBox(width: 4),
              Text(period, style: AppTextStyles.captionMuted(context)),
            ],
          ),
          const SizedBox(height: 24),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(f, style: AppTextStyles.body(context))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: secondary
                    ? theme.colorScheme.surface
                    : theme.colorScheme.primary,
                foregroundColor: secondary
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
