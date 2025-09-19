import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phf/sevices/database_service.dart';
import 'package:phf/sevices/service_methods.dart';
import 'package:phf/models/items.dart';
import 'package:phf/models/navigation_category.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String homePageContent = 'loading...';

  @override
  void initState() {
    getHomePageContent().then((val){
      setState(() {
        homePageContent = val.toString();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('PHF'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          // Top Navigation Bar with Categories
          FutureBuilder<List<NavigationCategory>>(
            future: getNavigationCategories(),
            builder: (context, categorySnapshot) {
              if (categorySnapshot.hasData) {
                return TopNavBar(
                  key: ValueKey('topNav'),
                  topNavBarList: categorySnapshot.data!,
                );
              } else {
                return Container(
                  height: ScreenUtil().setHeight(320),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
          // Items Grid
          Expanded(
            child: FutureBuilder<List<Items>>(
              future: getHomePageContent(),
              builder: (context, itemsSnapshot) {
                if (itemsSnapshot.hasData) {
                  List<Items> items = itemsSnapshot.data!;
                  return GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                                child: item.image.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                        child: Image.network(
                                          item.image,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(Icons.image_not_supported, size: 50);
                                          },
                                        ),
                                      )
                                    : Icon(Icons.image, size: 50),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.itemName,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '\$${item.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TopNavBar extends StatelessWidget {
  final List<NavigationCategory> topNavBarList;
  const TopNavBar({required Key key, required this.topNavBarList}) : super(key: key);

  Widget _gridViewBuilder(BuildContext context, NavigationCategory category) {
    return InkWell(
      onTap: () {
        print('Navigation clicked: ${category.name}');
        // You can add navigation logic here
        // Navigator.pushNamed(context, category.route ?? '/category/${category.id}');
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Display category icon from Google Cloud Storage URL
          Image.network(
            category.image, // This should be the Google Cloud Storage URL for the category icon
            width: ScreenUtil().setWidth(60), //95
            height: ScreenUtil().setHeight(60),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.category, size: 23); //40
            },
          ),
          SizedBox(height: 2.3),
          Text(
            category.name, // Category name like "Electronics", "Clothing", etc.
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(320),
      padding: EdgeInsets.all(1),
      child: GridView.count(
        crossAxisCount: 4,
        childAspectRatio: 1.2, // Adjust this value to control row spacing
        padding: EdgeInsets.all(1),
        children: topNavBarList.map((category) {
          return _gridViewBuilder(context, category);
        }).toList(),
      ),
    );
  }
}