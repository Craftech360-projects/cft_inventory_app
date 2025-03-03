import 'dart:math';

import 'package:app/functions/fetch_from_supabase.dart';
import 'package:app/functions/print_label_from_card.dart';
import 'package:app/functions/print_label_from_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _inventoryCodeController =
      TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _description1Controller = TextEditingController();
  final TextEditingController _description2Controller = TextEditingController();
  final TextEditingController _description3Controller = TextEditingController();
  final TextEditingController _description4Controller = TextEditingController();

  List<Map<String, String>> _data = [];
  List<Map<String, String>> _filteredData = [];

  int _currentPage = 0;
  final int _itemsPerPage = 15;
  String _searchQuery = '';

  bool _isLoading = false;
  bool _showLoadMoreButton = false;

  @override
  void initState() {
    super.initState();
    _fetchData();

    final supabase = Supabase.instance.client;
    supabase.from('products').stream(primaryKey: ['id']).listen((payload) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await fetchSupabaseData();
      setState(() {
        _data = data;
        _applyFilter();
      });
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredData = List.from(_data);
    } else {
      _filteredData = _data.where((item) {
        final sku = item['sku'] ?? '';
        final productName = item['product_name'] ?? '';
        return sku.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            productName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    // Reset to first page when filter changes
    _currentPage = 0;
  }

  void _loadMoreItems() {
    setState(() {
      _currentPage++;
    });
  }

  bool get _hasMoreItems {
    return _filteredData.length > (_currentPage + 1) * _itemsPerPage;
  }

  List<Map<String, String>> get _paginatedData {
    final startIndex = 0;
    final endIndex =
        min((_currentPage + 1) * _itemsPerPage, _filteredData.length);
    return _filteredData.sublist(startIndex, endIndex);
  }

  // Add this helper method to determine when to show the load more button
  bool _shouldShowLoadMoreButton(ScrollNotification notification) {
    return _hasMoreItems &&
        notification.metrics.pixels >= notification.metrics.maxScrollExtent;
  }

  void _printLabelFromCard(Map<String, String> item) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await printLabelFromCard(item, context);
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing label: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _printLabelFromInputs() async {
    final inventoryCode = _inventoryCodeController.text;
    final product = _productController.text;
    final description1 = _description1Controller.text;
    final description2 = _description2Controller.text;
    final description3 = _description3Controller.text;
    final description4 = _description4Controller.text;

    if (inventoryCode.isEmpty || product.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Please fill the required fields!',
          style: TextStyle(fontSize: 16),
        )),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await printLabelFromInputs(inventoryCode, product, description1,
          description2, description3, description4, context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing label: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            'CFT Inventory App',
            style: TextStyle(fontSize: 18),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Inventory List'),
              Tab(text: 'Print Label'),
            ],
          ),
        ),
        body: TabBarView(children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 14),
                    hintText: 'Search by SKU or Product Name',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _applyFilter();
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilter();
                    });
                  },
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _filteredData.isEmpty
                        ? Center(child: Text('No items found'))
                        : NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification notification) {
                              if (_shouldShowLoadMoreButton(notification)) {
                                setState(() {
                                  _showLoadMoreButton = true;
                                });
                              } else {
                                setState(() {
                                  _showLoadMoreButton = false;
                                });
                              }
                              return false;
                            },
                            child: Stack(
                              children: [
                                ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  padding: EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                    top: 8.0,
                                    bottom: _showLoadMoreButton
                                        ? 40.0
                                        : 8.0, // Add padding at bottom if we have more items
                                  ),
                                  itemCount: _paginatedData.length,
                                  itemBuilder: (context, index) {
                                    final item = _paginatedData[index];
                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('• SKU: ${item['sku']}'),
                                            Text(
                                                '• Product: ${item['product_name']}'),
                                            Text(
                                                '• Category: ${item['category']}'),
                                            Text(
                                                '• Sub Category: ${item['sub_category']}'),
                                            Text(
                                                '• Description: ${item['description']}'),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.close,
                                                      color: Colors.red),
                                                  onPressed: () {
                                                    // Handle cross button action
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.check,
                                                      color: Colors.green),
                                                  onPressed: () =>
                                                      _printLabelFromCard(item),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (_showLoadMoreButton && _hasMoreItems)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Padding(
                                      padding: EdgeInsets.all(3),
                                      child: TextButton(
                                        onPressed: _loadMoreItems,
                                        child: Text(
                                          ' Load More... ',
                                          style: TextStyle(
                                              backgroundColor: Colors.black,
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
              ),
            ],
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 120,
                        child: TextField(
                          maxLength: 2,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Label Width",
                            counterText: "",
                            border: OutlineInputBorder(),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^[5-9][0-9]|[1-9][0-9]{2,}$')),
                          ],
                          controller: TextEditingController(text: '50'),
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          maxLength: 2,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Label Height",
                            counterText: "",
                            border: OutlineInputBorder(),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^[2-9][5-9]|[3-9][0-9]{2,}$')),
                          ],
                          controller: TextEditingController(text: '30'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextField(
                    maxLength: 20,
                    controller: _inventoryCodeController,
                    decoration: InputDecoration(labelText: 'Inventory Code'),
                  ),
                  TextField(
                    maxLength: 22,
                    controller: _productController,
                    decoration:
                        InputDecoration(labelText: 'Product and Processor'),
                  ),
                  TextField(
                    maxLength: 20,
                    controller: _description1Controller,
                    decoration:
                        InputDecoration(labelText: 'RAM/SSD - Graphics Card'),
                  ),
                  TextField(
                    maxLength: 20,
                    controller: _description2Controller,
                    decoration: InputDecoration(labelText: 'Serial Number'),
                  ),
                  TextField(
                    maxLength: 20,
                    controller: _description3Controller,
                    decoration: InputDecoration(labelText: 'Purpose - User'),
                  ),
                  TextField(
                    maxLength: 20,
                    controller: _description4Controller,
                    decoration: InputDecoration(labelText: 'Additional Info'),
                  ),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white),
                          onPressed: _printLabelFromInputs,
                          child: Text('Print Label'),
                        ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
