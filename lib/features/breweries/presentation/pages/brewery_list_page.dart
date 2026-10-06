import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/forest_colors.dart';
import '../../../../core/widgets/forest_button.dart';
import '../../domain/entities/brewery.dart';
import '../bloc/brewery_list/brewery_list_bloc.dart';
import '../widgets/brewery_tile.dart';
import '../widgets/message_view.dart';

class BreweryListPage extends StatelessWidget {
  const BreweryListPage({super.key, required this.onBreweryTap});

  final ValueChanged<Brewery> onBreweryTap;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            const _Header(),
            Expanded(
              child: BlocBuilder<BreweryListBloc, BreweryListState>(
                builder: (context, state) => switch (state) {
                  BreweryListInitial() || BreweryListLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  BreweryListEmpty(:final query) => MessageView(
                    icon: Icons.search_off,
                    title: 'No breweries',
                    message: query.isEmpty
                        ? 'There is nothing to show yet.'
                        : 'Nothing matches "$query". Try another name or city.',
                  ),
                  BreweryListFailure(:final message) => MessageView(
                    icon: Icons.cloud_off,
                    title: 'Something went wrong',
                    message: message,
                    actionLabel: 'Try again',
                    onAction: () => context.read<BreweryListBloc>().add(
                      const BreweryListRetried(),
                    ),
                  ),
                  BreweryListLoaded() => _BreweryList(
                    state: state,
                    onBreweryTap: onBreweryTap,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FIND A BREWERY',
                style: ForestText.display(
                  fontSize: 32,
                  color: ForestColors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Explore breweries from Open Brewery DB',
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: ForestColors.mistGreen),
              ),
              const SizedBox(height: 16),
              const _SearchField(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField();

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    // Rebuild to toggle the clear button; the Bloc debounces the search.
    setState(() {});
    context.read<BreweryListBloc>().add(BreweryListSearchChanged(query));
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search by name or city',
        prefixIcon: const Icon(Icons.search, color: ForestColors.forestGreen),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close, color: ForestColors.forestGreen),
                onPressed: _clear,
              ),
      ),
    );
  }
}

class _BreweryList extends StatefulWidget {
  const _BreweryList({required this.state, required this.onBreweryTap});

  final BreweryListLoaded state;
  final ValueChanged<Brewery> onBreweryTap;

  @override
  State<_BreweryList> createState() => _BreweryListState();
}

class _BreweryListState extends State<_BreweryList> {
  static const _loadMoreThreshold = 400.0;

  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = widget.state;
    // After a failed page, wait for an explicit retry instead of
    // re-firing on every scroll tick.
    if (state.nextPageError != null) return;
    if (_controller.position.extentAfter < _loadMoreThreshold) {
      context.read<BreweryListBloc>().add(const BreweryListNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final showFooter =
        state.hasMore || state.isLoadingMore || state.nextPageError != null;
    return ListView.separated(
      controller: _controller,
      padding: EdgeInsets.fromLTRB(
        16,
        20,
        16,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: state.items.length + (showFooter ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (index == state.items.length) return _ListFooter(state: state);
        final brewery = state.items[index];
        return BreweryTile(
          brewery: brewery,
          onTap: () => widget.onBreweryTap(brewery),
        );
      },
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state});

  final BreweryListLoaded state;

  @override
  Widget build(BuildContext context) {
    final error = state.nextPageError;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: ForestColors.darkGray),
            ),
            const SizedBox(height: 12),
            ForestButton(
              label: 'Load more',
              compact: true,
              variant: ForestButtonVariant.secondary,
              onPressed: () => context.read<BreweryListBloc>().add(
                const BreweryListNextPageRequested(),
              ),
            ),
          ],
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
