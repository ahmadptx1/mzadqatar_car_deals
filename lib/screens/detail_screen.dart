import 'package:flutter/material.dart';
import '../models/car_listing.dart';
import '../models/comment.dart';
import '../models/product_details.dart';
import '../api/mzadqatar_api.dart';

class DetailScreen extends StatefulWidget {
  final CarListing car;

  const DetailScreen({super.key, required this.car});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<ProductDetails> _productDetailsFuture;
  late Future<List<Comment>> _commentsFuture;
  late Future<List<CarListing>> _relatedAdsFuture;

  @override
  void initState() {
    super.initState();
    final productId = widget.car.id ?? 1; // Use 1 as fallback for mock data
    _productDetailsFuture = MzadQatarApi.getProductDetails(productId);
    _commentsFuture = MzadQatarApi.getProductComments(productId);
    _relatedAdsFuture = MzadQatarApi.getRelatedUserAds(
      widget.car.sellerId ?? 'user1',
      limit: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Details Section
            FutureBuilder<ProductDetails>(
              future: _productDetailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return _buildBasicCarInfo();
                } else if (snapshot.hasData) {
                  return _buildDetailedCarInfo(snapshot.data!);
                }
                return _buildBasicCarInfo();
              },
            ),
            
            const SizedBox(height: 24),
            
            // Comments Section
            const Text(
              'Comments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Comment>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error loading comments: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return _buildCommentsSection(snapshot.data!);
                }
                return const Text('No comments yet.');
              },
            ),
            
            const SizedBox(height: 24),
            
            // Related Ads Section
            const Text(
              'More from this seller',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<CarListing>>(
              future: _relatedAdsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error loading related ads: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return _buildRelatedAdsSection(snapshot.data!);
                }
                return const Text('No related ads found.');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicCarInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.car.imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.car.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.car_rental, size: 50),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        Text(
          widget.car.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'QAR ${widget.car.price}',
          style: const TextStyle(fontSize: 18, color: Colors.blue),
        ),
        const SizedBox(height: 16),
        Text(widget.car.description),
        const SizedBox(height: 16),
        Text('Posted at: ${widget.car.postedAt.toLocal()}'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Open URL in browser
            // You may want to use url_launcher package for real implementation
          },
          child: const Text('View Original Listing'),
        ),
      ],
    );
  }

  Widget _buildDetailedCarInfo(ProductDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image gallery
        if (details.images.isNotEmpty)
          SizedBox(
            height: 200,
            child: PageView.builder(
              itemCount: details.images.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    details.images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.car_rental, size: 50),
                      );
                    },
                  ),
                );
              },
            ),
          )
        else if (details.imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              details.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.car_rental, size: 50),
                );
              },
            ),
          ),
        
        const SizedBox(height: 16),
        Text(
          details.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'QAR ${details.price}',
          style: const TextStyle(fontSize: 18, color: Colors.blue),
        ),
        const SizedBox(height: 16),
        
        // Car specifications
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Car Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Brand', details.brand),
                _buildDetailRow('Model', details.model),
                _buildDetailRow('Year', details.year.toString()),
                _buildDetailRow('Mileage', '${details.mileage} km'),
                _buildDetailRow('Fuel Type', details.fuelType),
                _buildDetailRow('Transmission', details.transmission),
                _buildDetailRow('Location', details.location),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Seller information
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seller Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Name', details.sellerName),
                _buildDetailRow('Phone', details.sellerPhone),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        Text(details.description),
        
        if (details.features.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Features',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: details.features.map((feature) => Chip(
              label: Text(feature),
              backgroundColor: Colors.blue[50],
            )).toList(),
          ),
        ],
        
        const SizedBox(height: 16),
        Text('Posted at: ${details.postedAt.toLocal()}'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // Open URL in browser
          },
          child: const Text('View Original Listing'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(List<Comment> comments) {
    return Column(
      children: comments.map((comment) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (comment.rating != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(comment.rating!.toStringAsFixed(1)),
                      ],
                    ),
                  const SizedBox(width: 8),
                  Text(
                    comment.createdAt.toLocal().toString().split(' ')[0],
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(comment.content),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildRelatedAdsSection(List<CarListing> relatedAds) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: relatedAds.length,
        itemBuilder: (context, index) {
          final ad = relatedAds[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      child: Image.network(
                        ad.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.car_rental),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ad.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'QAR ${ad.price}',
                          style: const TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}