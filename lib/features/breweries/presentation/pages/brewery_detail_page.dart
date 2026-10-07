import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/forest_colors.dart';
import '../../../../core/widgets/forest_button.dart';
import '../../../../core/widgets/forest_card.dart';
import '../../../../core/widgets/forest_pill.dart';
import '../../domain/entities/brewery.dart';
import '../bloc/brewery_detail/brewery_detail_cubit.dart';
import '../widgets/brewery_formatting.dart';
import '../widgets/message_view.dart';

class BreweryDetailPage extends StatelessWidget {
  const BreweryDetailPage({
    super.key,
    required this.breweryId,
    required this.initialName,
  });

  final String breweryId;

  /// Shown in the header while the detail request is in flight.
  final String initialName;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: BlocBuilder<BreweryDetailCubit, BreweryDetailState>(
          builder: (context, state) => switch (state) {
            BreweryDetailLoading() => Column(
              children: [
                _Header(name: initialName),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
            BreweryDetailFailure(:final message, :final canRetry) => Column(
              children: [
                _Header(name: initialName),
                Expanded(
                  child: MessageView(
                    icon: canRetry ? Icons.cloud_off : Icons.search_off,
                    title: canRetry ? 'Something went wrong' : 'Not found',
                    message: message,
                    actionLabel: canRetry ? 'Try again' : null,
                    onAction: () =>
                        context.read<BreweryDetailCubit>().load(breweryId),
                  ),
                ),
              ],
            ),
            BreweryDetailLoaded(:final brewery) => _BreweryDetails(
              brewery: brewery,
            ),
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, this.brewery});

  final String name;

  /// Null while loading: only the name is known then.
  final Brewery? brewery;

  @override
  Widget build(BuildContext context) {
    final location = brewery?.location;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: ForestColors.pineGreen,
        border: Border(
          bottom: BorderSide(
            color: ForestColors.forestGreen,
            width: AppTheme.borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackButton(color: ForestColors.white),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (brewery != null) ...[
                      ForestPill(
                        label: brewery!.type.label,
                        background: ForestColors.mistGreen,
                        foreground: ForestColors.forestGreen,
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      name.toUpperCase(),
                      style: ForestText.display(
                        fontSize: 30,
                        color: ForestColors.white,
                      ),
                    ),
                    if (location != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        location,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(color: ForestColors.mistGreen),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreweryDetails extends StatelessWidget {
  const _BreweryDetails({required this.brewery});

  final Brewery brewery;

  @override
  Widget build(BuildContext context) {
    final phone = brewery.phone;
    final website = brewery.websiteUrl;
    final phoneUri = phone == null ? null : Uri(scheme: 'tel', path: phone);
    final websiteUri = website == null ? null : Uri.tryParse(website);

    return Column(
      children: [
        _Header(name: brewery.name, brewery: brewery),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            children: [
              ForestCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.place_outlined,
                      label: 'Address',
                      value: brewery.fullAddress,
                    ),
                    const Divider(height: 1, indent: 64),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: phone,
                    ),
                    const Divider(height: 1, indent: 64),
                    _InfoRow(
                      icon: Icons.language,
                      label: 'Website',
                      value: website,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (phoneUri != null || websiteUri != null)
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (websiteUri != null)
                  ForestButton(
                    label: 'Visit website',
                    icon: Icons.language,
                    variant: ForestButtonVariant.secondary,
                    onPressed: () => _launch(context, websiteUri),
                  ),
                if (phoneUri != null && websiteUri != null)
                  const SizedBox(height: 14),
                if (phoneUri != null)
                  ForestButton(
                    label: 'Call',
                    icon: Icons.phone,
                    onPressed: () => _launch(context, phoneUri),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _launch(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    bool launched;
    try {
      launched = await launchUrl(uri);
    } on PlatformException {
      launched = false;
    }
    if (!launched) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open this link.')),
      );
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ForestColors.leafGreen, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(
                    color: ForestColors.darkGray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? 'Not available',
                  style: textTheme.bodyLarge?.copyWith(
                    color: value == null
                        ? ForestColors.darkGray
                        : ForestColors.forestGreen,
                    fontWeight: value == null ? null : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
