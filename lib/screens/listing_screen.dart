import 'package:flutter/material.dart';
import '../models/car_listing.dart';
import '../models/category.dart';
import '../api/mzadqatar_api.dart';
import 'detail_screen.dart';
import '../utils/analysis.dart';

class ListingScreen extends StatefulWidget {
  const ListingScreen({super.key});

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  List<CarListing> _listings = [];
  List<Category> _categories = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool isRefresh = false}) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      if (isRefresh) {
        _currentPage = 1;
        _listings.clear();
      }
    });

    try {
      final result = await MzadQatarApi.getCategoryData(
        page: _currentPage,
        category: _selectedCategory,
      );
      
      setState(() {
        if (isRefresh) {
          _listings = result['listings'];
        } else {
          _listings.addAll(result['listings']);
        }
        _categories = result['categories'];
        _totalPages = result['totalPages'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (_currentPage < _totalPages && !_isLoading) {
      _currentPage++;
      await _loadData();
    }
  }

  Future<void> _refreshData() async {
    await _loadData(isRefresh: true);
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
    });
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MzadQatar Car Deals'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: _filterByCategory,
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: null,
                child: Text('All Categories'),
              ),
              ..._categories.map((category) => PopupMenuItem<String>(
                value: category.name,
                child: Text('${category.name} (${category.count})'),
              )),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () async {
              if (_listings.isNotEmpty) {
                final stats = analyzeListings(_listings);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Market Analysis'),
                    content: Text(stats),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            // Category filter chip bar
            if (_categories.isNotEmpty)
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All'),
                          selected: _selectedCategory == null,
                          onSelected: (_) => _filterByCategory(null),
                        ),
                      );
                    }
                    final category = _categories[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('${category.name} (${category.count})'),
                        selected: _selectedCategory == category.name,
                        onSelected: (_) => _filterByCategory(category.name),
                      ),
                    );
                  },
                ),
              ),
            
            // Listings
            Expanded(
              child: _listings.isEmpty && !_isLoading
                  ? const Center(child: Text('No listings found.'))
                  : ListView.builder(
                      itemCount: _listings.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _listings.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
                        final car = _listings[index];
                        
                        // Load next page when reaching near end
                        if (index == _listings.length - 3) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _loadNextPage();
                          });
                        }
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: car.imageUrl.isNotEmpty
                                  ? Image.network(
                                      car.imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.car_rental),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.car_rental),
                                    ),
                            ),
                            title: Text(
                              car.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'QAR ${car.price}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  car.postedAt.toLocal().toString().split(' ')[0],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailScreen(car: car),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
            
            // Pagination info
            if (_listings.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Page $_currentPage of $_totalPages • ${_listings.length} listings',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}