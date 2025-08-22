import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tomato/models/restaurant_model.dart';
import 'package:tomato/models/category_model.dart';
import 'package:tomato/services/api_service.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String userName = "";
  bool isLoadingCategories = true;
  bool isLoadingRestaurants = true;
  String? selectedCategory;
  List<CategoryModel> categories = [];
  List<RestaurantModel> restaurants = [];
  List<RestaurantModel> allRestaurants = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadData();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "Guest";
    });
  }

  Future<void> _loadData() async {
    setState(() {
      isLoadingCategories = true;
      isLoadingRestaurants = true;
      errorMessage = null;
    });

    try {
      final fetchedCategories = await ApiService.fetchCategories();
      final fetchedRestaurants = await ApiService.fetchRestaurants();
      if (!mounted) return;
      setState(() {
        categories = fetchedCategories;
        restaurants = fetchedRestaurants;
        allRestaurants = fetchedRestaurants;
        isLoadingCategories = false;
        isLoadingRestaurants = false;
      });
    } catch (e) {
      setState(() {
        isLoadingCategories = false;
        isLoadingRestaurants = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _selectCategory(String? category) async {
    setState(() {
      selectedCategory = category;
      isLoadingRestaurants = true;
      errorMessage = null;
    });

    try {
      final fetched = await ApiService.fetchRestaurants(category: category);
      if (!mounted) return;
      setState(() {
        restaurants = fetched;
        allRestaurants = fetched;
        isLoadingRestaurants = false;
      });
    } catch (e) {
      setState(() {
        isLoadingRestaurants = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // Display image safely (handles URL and base64)
  Widget _buildImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        color: Colors.grey[200],
        height: 150,
        width: double.infinity,
        child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      );
    }

    if (imagePath.startsWith("data:image")) {
      final base64Str = imagePath.split(',').last;
      final bytes = base64Decode(base64Str);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 150,
        errorBuilder: (_, __, ___) => Container(
          height: 150,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        ),
      );
    }

    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 150,
      errorBuilder: (_, __, ___) => Container(
        height: 150,
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: const Color(0xFFe23744),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                style: const TextStyle(
                  color: Color(0xFFe23744),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFFe23744)),
              accountName: Text(userName),
              accountEmail: const Text(""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                  style: const TextStyle(
                    color: Color(0xFFe23744),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
          if (selectedCategory != null) {
            await _selectCategory(selectedCategory);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              _buildSearchBar(),
              _buildPromoBanner(),
              _buildCategorySection(),
              _buildFilterChips(),
              _buildRestaurantSection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.red, size: 20),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              "Shivalik Sharda Park View 2 Rd...",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (selectedCategory != null)
            TextButton(
              onPressed: () => _selectCategory(null),
              child: const Text(
                "Clear",
                style: TextStyle(color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Restaurant name or a dish...",
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (q) {
          final lower = q.toLowerCase();
          setState(() {
            restaurants = allRestaurants
                .where((r) => (r.name ?? "").toLowerCase().contains(lower))
                .toList();
          });
        },
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Get ₹50 OFF & FREE delivery",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("on your first order under 7 km",
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
        Image.network(
          "https://cdn-icons-png.flaticon.com/512/1046/1046784.png",
          width: 50,
          height: 50,
        ),
      ]),
    );
  }

  Widget _buildCategorySection() {
    if (isLoadingCategories) {
      return SizedBox(
        height: 110,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = (selectedCategory ?? "").toLowerCase() ==
              (cat.name ?? "").toLowerCase();
          return GestureDetector(
            onTap: () => _selectCategory(cat.name),
            child: Container(
              width: 86,
              padding: const EdgeInsets.all(6),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[100],
                    backgroundImage: null,
                    child: _buildImage(cat.image),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat.name ?? "",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final chips = ["Filters", "Under ₹200", "Under 30 mins", "Pure Veg"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: chips.map((c) => Chip(label: Text(c))).toList(),
      ),
    );
  }

  Widget _buildRestaurantSection() {
    if (isLoadingRestaurants) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text("Error: $errorMessage")),
      );
    }
    if (restaurants.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text("No restaurants found")),
      );
    }
    return Column(
      children: restaurants.map((r) => _restaurantCard(r)).toList(),
    );
  }

  Widget _restaurantCard(RestaurantModel r) {
    final price = r.priceForOne ?? 0;
    final rating = r.rating ?? 0.0;
    final time = r.deliveryTime?.isNotEmpty == true ? r.deliveryTime! : "N/A";
    final categoriesList = (r.categories != null && r.categories!.isNotEmpty)
        ? r.categories!.join(', ')
        : "Various";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(12)),
            child: _buildImage(r.image),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name ?? "",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        "$categoriesList • ₹$price for one",
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(time, style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining), label: "Delivery"),
        BottomNavigationBarItem(
            icon: Icon(Icons.restaurant), label: "Dining"),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag), label: "Orders"),
      ],
    );
  }
}
