import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:yoloikan/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/history_item.dart';
import '../../services/history_repository.dart';
import '../../services/ikan_repository.dart';
import '../../widgets/responsive_center.dart';
import '../detail/species_detail_view.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView>
    with AutomaticKeepAliveClientMixin {
  late Future<List<HistoryItem>> _future;
  String _query = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _future = HistoryRepository.getAll();
    HistoryRepository.revision.addListener(_reload);
  }

  @override
  void dispose() {
    HistoryRepository.revision.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _future = HistoryRepository.getAll());
  }

  Future<bool> _confirmDeleteItem() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteHistoryItemConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 720,
          child: FutureBuilder<List<HistoryItem>>(
            future: _future,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              final filtered = _query.isEmpty
                  ? items
                  : items
                        .where(
                          (e) => e.className.toLowerCase().contains(
                            _query.toLowerCase(),
                          ),
                        )
                        .toList();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Text(
                        l10n.historyTitle,
                        style: AppTextStyles.titleLarge,
                      ),
                    ),
                  ),
                  if (items.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              onChanged: (v) => setState(() => _query = v),
                              decoration: InputDecoration(
                                hintText: l10n.searchSpeciesHint,
                                hintStyle: AppTextStyles.bodyMedium,
                                prefixIcon: const Icon(Icons.search_rounded),
                                filled: true,
                                fillColor: AppColors.surfaceContainerLowest,
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: AppColors.outlineVariant.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.swipeToDeleteHint,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(
                        hasQuery: _query.isNotEmpty,
                        l10n: l10n,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = filtered[index];
                          return Dismissible(
                            key: ValueKey(item.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) => _confirmDeleteItem(),
                            onDismissed: (_) async {
                              await HistoryRepository.deleteById(item.id);
                              _reload();
                            },
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                              ),
                            ),
                            child: _HistoryCard(
                              item: item,
                              onTap: () => _openDetail(item),
                            ),
                          );
                        }, childCount: filtered.length),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openDetail(HistoryItem item) async {
    final species = await IkanRepository.findById(item.classIndex);
    if (species == null || !mounted) return;

    Uint8List? photoBytes;
    final path = item.photoPath;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        photoBytes = await file.readAsBytes();
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushNamed(
      AppConstants.detailRoute,
      arguments: SpeciesDetailArgs(
        className: item.className,
        confidence: item.confidence,
        species: species,
        photo: photoBytes,
        timestamp: item.timestamp,
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback onTap;

  const _HistoryCard({required this.item, required this.onTap});

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: IkanRepository.findById(item.classIndex),
      builder: (context, snapshot) {
        final species = snapshot.data;
        final color = species?.warna ?? AppColors.secondary;
        final name = species?.nama ?? item.className;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppColors.cardShadow],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: item.photoPath != null
                        ? Image.file(
                            File(item.photoPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _Fallback(color: color),
                          )
                        : _Fallback(color: color),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(item.timestamp),
                        style: AppTextStyles.monoData,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    '${(item.confidence * 100).toStringAsFixed(1)}%',
                    style: AppTextStyles.monoData.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Fallback extends StatelessWidget {
  final Color color;
  const _Fallback({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withValues(alpha: 0.15),
      child: Icon(Icons.set_meal_rounded, color: color, size: 28),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasQuery;
  final AppLocalizations l10n;
  const _EmptyState({required this.hasQuery, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 56,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              hasQuery ? l10n.noMatchingResults : l10n.noHistoryYet,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
