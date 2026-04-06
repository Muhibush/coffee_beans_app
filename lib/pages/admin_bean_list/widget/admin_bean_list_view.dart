import 'package:flutter/material.dart';
import 'package:coffee_beans_app/utils/design_system/app_theme.dart';
import 'package:coffee_beans_app/pages/admin_dashboard/widget/sticky_search_filter.dart';
import 'scraper_input.dart';
import 'admin_bean_card.dart';

enum BeanStatusFilter { all, published, draft, unpublished }

class AdminBeanListView extends StatefulWidget {
  const AdminBeanListView({super.key});

  @override
  State<AdminBeanListView> createState() => _AdminBeanListViewState();
}

class _AdminBeanListViewState extends State<AdminBeanListView> {
  final TextEditingController _searchController = TextEditingController();
  BeanStatusFilter _activeFilter = BeanStatusFilter.all;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _dummyBeans = [
    {
      'title': 'Ethiopia Guji',
      'price': 'Rp 85.000',
      'status': 'published',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC4CvGI_BJqnCC6sNcEqTxBZgRNtywgBvOkAs0U8RCzM8_0_XMetFziJJrCvQ_Hf15r7Qg1PxGS78S6M2G1jvrDBVoW8H6BWZro5K-ovlsHIruMwdetHTj4bm0qgWSeZTqC5H6Af2hzt2ch77liNd_jo-SjKqnrXusTdXzgszDbNi_Kj0h4_P1SVWt198_IHd0nWk9D-mjSSNAejHXXOvtd-UUGwAcfn162lvpHfJZZiLMTVpTB2JQDNFoE5cHkWOvHjuvL1tiBdRrv',
    },
    {
      'title': 'Watermelon Smash',
      'price': 'Rp 96.570',
      'status': 'draft',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDfHCkg8cqPPWFPG7HUimWv-E1DCY3sLsjKPo8TsL-tNqmu-wvODEXZZzk9RgOs0Jl2pQ-uogzDVLpSp9q_IexPEIUc-caorV3NH-USS81mg2Wv92HjUHKgZT0qGdnQdb7nCmCfttS2KqvsfLBfongBJDGZ5r5LCvgsKaU73FP7OP9Ri8skVrYUM_UfqI2vO0pkkOukUiI9Y_hb5SVVWiFkX3My1NmxLcS15qMSIk9qMUpS5CIBzSzLJCkexT1-mctgA3A2K9DeJXH2',
    },
    {
      'title': 'Aceh Gayo',
      'price': 'Rp 120.000',
      'status': 'unpublished',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAeFdZzxnyBuQZ4b0SoFUvgdpi5TBL3INrm4063PWfqg7cfgIrYl44n2AjKgbVumyRzO6mqphQPJ1TD7SCSr7e5_mMNUWkGPw8mCByzv-HJpEG7anu2Kk1xnsvskMolktA9oYnd5-9At0OiNvagBh55R7WgadZWPbzKvcuywmsmEeHyyC7OKnziwGu3FdNJUOmolKlkeaLia0Gj_YDg89fuSl0TNsUSYWSp2r00Znp-KK41DIneETZdrOz1NpJzyflj6B1yAEwqHKQS',
    },
    {
      'title': 'Ethiopia Guji',
      'price': 'Rp 85.000',
      'status': 'published',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC4CvGI_BJqnCC6sNcEqTxBZgRNtywgBvOkAs0U8RCzM8_0_XMetFziJJrCvQ_Hf15r7Qg1PxGS78S6M2G1jvrDBVoW8H6BWZro5K-ovlsHIruMwdetHTj4bm0qgWSeZTqC5H6Af2hzt2ch77liNd_jo-SjKqnrXusTdXzgszDbNi_Kj0h4_P1SVWt198_IHd0nWk9D-mjSSNAejHXXOvtd-UUGwAcfn162lvpHfJZZiLMTVpTB2JQDNFoE5cHkWOvHjuvL1tiBdRrv',
    },
    {
      'title': 'Watermelon Smash',
      'price': 'Rp 96.570',
      'status': 'draft',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDfHCkg8cqPPWFPG7HUimWv-E1DCY3sLsjKPo8TsL-tNqmu-wvODEXZZzk9RgOs0Jl2pQ-uogzDVLpSp9q_IexPEIUc-caorV3NH-USS81mg2Wv92HjUHKgZT0qGdnQdb7nCmCfttS2KqvsfLBfongBJDGZ5r5LCvgsKaU73FP7OP9Ri8skVrYUM_UfqI2vO0pkkOukUiI9Y_hb5SVVWiFkX3My1NmxLcS15qMSIk9qMUpS5CIBzSzLJCkexT1-mctgA3A2K9DeJXH2',
    },
    {
      'title': 'Aceh Gayo',
      'price': 'Rp 120.000',
      'status': 'unpublished',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAeFdZzxnyBuQZ4b0SoFUvgdpi5TBL3INrm4063PWfqg7cfgIrYl44n2AjKgbVumyRzO6mqphQPJ1TD7SCSr7e5_mMNUWkGPw8mCByzv-HJpEG7anu2Kk1xnsvskMolktA9oYnd5-9At0OiNvagBh55R7WgadZWPbzKvcuywmsmEeHyyC7OKnziwGu3FdNJUOmolKlkeaLia0Gj_YDg89fuSl0TNsUSYWSp2r00Znp-KK41DIneETZdrOz1NpJzyflj6B1yAEwqHKQS',
    },
    {
      'title': 'Ethiopia Guji',
      'price': 'Rp 85.000',
      'status': 'published',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC4CvGI_BJqnCC6sNcEqTxBZgRNtywgBvOkAs0U8RCzM8_0_XMetFziJJrCvQ_Hf15r7Qg1PxGS78S6M2G1jvrDBVoW8H6BWZro5K-ovlsHIruMwdetHTj4bm0qgWSeZTqC5H6Af2hzt2ch77liNd_jo-SjKqnrXusTdXzgszDbNi_Kj0h4_P1SVWt198_IHd0nWk9D-mjSSNAejHXXOvtd-UUGwAcfn162lvpHfJZZiLMTVpTB2JQDNFoE5cHkWOvHjuvL1tiBdRrv',
    },
    {
      'title': 'Watermelon Smash',
      'price': 'Rp 96.570',
      'status': 'draft',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDfHCkg8cqPPWFPG7HUimWv-E1DCY3sLsjKPo8TsL-tNqmu-wvODEXZZzk9RgOs0Jl2pQ-uogzDVLpSp9q_IexPEIUc-caorV3NH-USS81mg2Wv92HjUHKgZT0qGdnQdb7nCmCfttS2KqvsfLBfongBJDGZ5r5LCvgsKaU73FP7OP9Ri8skVrYUM_UfqI2vO0pkkOukUiI9Y_hb5SVVWiFkX3My1NmxLcS15qMSIk9qMUpS5CIBzSzLJCkexT1-mctgA3A2K9DeJXH2',
    },
    {
      'title': 'Aceh Gayo',
      'price': 'Rp 120.000',
      'status': 'unpublished',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAeFdZzxnyBuQZ4b0SoFUvgdpi5TBL3INrm4063PWfqg7cfgIrYl44n2AjKgbVumyRzO6mqphQPJ1TD7SCSr7e5_mMNUWkGPw8mCByzv-HJpEG7anu2Kk1xnsvskMolktA9oYnd5-9At0OiNvagBh55R7WgadZWPbzKvcuywmsmEeHyyC7OKnziwGu3FdNJUOmolKlkeaLia0Gj_YDg89fuSl0TNsUSYWSp2r00Znp-KK41DIneETZdrOz1NpJzyflj6B1yAEwqHKQS',
    },
    {
      'title': 'Ethiopia Guji',
      'price': 'Rp 85.000',
      'status': 'published',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC4CvGI_BJqnCC6sNcEqTxBZgRNtywgBvOkAs0U8RCzM8_0_XMetFziJJrCvQ_Hf15r7Qg1PxGS78S6M2G1jvrDBVoW8H6BWZro5K-ovlsHIruMwdetHTj4bm0qgWSeZTqC5H6Af2hzt2ch77liNd_jo-SjKqnrXusTdXzgszDbNi_Kj0h4_P1SVWt198_IHd0nWk9D-mjSSNAejHXXOvtd-UUGwAcfn162lvpHfJZZiLMTVpTB2JQDNFoE5cHkWOvHjuvL1tiBdRrv',
    },
    {
      'title': 'Watermelon Smash',
      'price': 'Rp 96.570',
      'status': 'draft',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDfHCkg8cqPPWFPG7HUimWv-E1DCY3sLsjKPo8TsL-tNqmu-wvODEXZZzk9RgOs0Jl2pQ-uogzDVLpSp9q_IexPEIUc-caorV3NH-USS81mg2Wv92HjUHKgZT0qGdnQdb7nCmCfttS2KqvsfLBfongBJDGZ5r5LCvgsKaU73FP7OP9Ri8skVrYUM_UfqI2vO0pkkOukUiI9Y_hb5SVVWiFkX3My1NmxLcS15qMSIk9qMUpS5CIBzSzLJCkexT1-mctgA3A2K9DeJXH2',
    },
    {
      'title': 'Aceh Gayo',
      'price': 'Rp 120.000',
      'status': 'unpublished',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAeFdZzxnyBuQZ4b0SoFUvgdpi5TBL3INrm4063PWfqg7cfgIrYl44n2AjKgbVumyRzO6mqphQPJ1TD7SCSr7e5_mMNUWkGPw8mCByzv-HJpEG7anu2Kk1xnsvskMolktA9oYnd5-9At0OiNvagBh55R7WgadZWPbzKvcuywmsmEeHyyC7OKnziwGu3FdNJUOmolKlkeaLia0Gj_YDg89fuSl0TNsUSYWSp2r00Znp-KK41DIneETZdrOz1NpJzyflj6B1yAEwqHKQS',
    },
    {
      'title': 'Ethiopia Guji',
      'price': 'Rp 85.000',
      'status': 'published',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC4CvGI_BJqnCC6sNcEqTxBZgRNtywgBvOkAs0U8RCzM8_0_XMetFziJJrCvQ_Hf15r7Qg1PxGS78S6M2G1jvrDBVoW8H6BWZro5K-ovlsHIruMwdetHTj4bm0qgWSeZTqC5H6Af2hzt2ch77liNd_jo-SjKqnrXusTdXzgszDbNi_Kj0h4_P1SVWt198_IHd0nWk9D-mjSSNAejHXXOvtd-UUGwAcfn162lvpHfJZZiLMTVpTB2JQDNFoE5cHkWOvHjuvL1tiBdRrv',
    },
    {
      'title': 'Watermelon Smash',
      'price': 'Rp 96.570',
      'status': 'draft',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDfHCkg8cqPPWFPG7HUimWv-E1DCY3sLsjKPo8TsL-tNqmu-wvODEXZZzk9RgOs0Jl2pQ-uogzDVLpSp9q_IexPEIUc-caorV3NH-USS81mg2Wv92HjUHKgZT0qGdnQdb7nCmCfttS2KqvsfLBfongBJDGZ5r5LCvgsKaU73FP7OP9Ri8skVrYUM_UfqI2vO0pkkOukUiI9Y_hb5SVVWiFkX3My1NmxLcS15qMSIk9qMUpS5CIBzSzLJCkexT1-mctgA3A2K9DeJXH2',
    },
    {
      'title': 'Aceh Gayo',
      'price': 'Rp 120.000',
      'status': 'unpublished',
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAeFdZzxnyBuQZ4b0SoFUvgdpi5TBL3INrm4063PWfqg7cfgIrYl44n2AjKgbVumyRzO6mqphQPJ1TD7SCSr7e5_mMNUWkGPw8mCByzv-HJpEG7anu2Kk1xnsvskMolktA9oYnd5-9At0OiNvagBh55R7WgadZWPbzKvcuywmsmEeHyyC7OKnziwGu3FdNJUOmolKlkeaLia0Gj_YDg89fuSl0TNsUSYWSp2r00Znp-KK41DIneETZdrOz1NpJzyflj6B1yAEwqHKQS',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredBeans {
    return _dummyBeans.where((bean) {
      if (_activeFilter != BeanStatusFilter.all &&
          bean['status'] != _activeFilter.name) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return bean['title'].toString().toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredBeans;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Beans'),
            backgroundColor: AppColors.surfaceBackground,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: ScraperInput(),
            ),
          ),

          SliverPersistentHeader(
            pinned: true,
            delegate: StickySearchFilter<BeanStatusFilter>(
              searchController: _searchController,
              searchHint: 'Search beans...',
              activeFilter: _activeFilter,
              filters: const [
                FilterOption(label: 'All', value: BeanStatusFilter.all),
                FilterOption(
                  label: 'Published',
                  value: BeanStatusFilter.published,
                ),
                FilterOption(label: 'Draft', value: BeanStatusFilter.draft),
                FilterOption(
                  label: 'Unpublished',
                  value: BeanStatusFilter.unpublished,
                ),
              ],
              onFilterChanged: (f) => setState(() => _activeFilter = f),
              onSearchChanged: (q) => setState(() => _searchQuery = q),
              resultCount: filtered.length,
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final bean = filtered[index];
                final isUnpublished = bean['status'] == 'unpublished';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Opacity(
                    opacity: isUnpublished ? 0.8 : 1.0,
                    key: ValueKey(bean['title']),
                    child: AdminBeanCard(
                      title: bean['title'],
                      price: bean['price'],
                      imageUrl: bean['imageUrl'],
                      status: bean['status'],
                    ),
                  ),
                );
              }, childCount: filtered.length),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

