import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/animation/animation.dart';
import 'package:food_recipe_app/models/auto_complete.dart';
import 'package:food_recipe_app/screens/home_screen/widgets/horizontal_list.dart';
import 'package:food_recipe_app/screens/recipe_info/bloc/recipe_info_bloc.dart';
import 'package:food_recipe_app/screens/recipe_info/recipe_info_screen.dart';
import 'package:food_recipe_app/screens/search_page/cubit/search_page_cubit.dart';
import 'package:food_recipe_app/screens/search_page/cubit/search_page_state.dart';
import 'package:food_recipe_app/screens/search_results/bloc/search_result_bloc.dart';
import 'package:food_recipe_app/screens/search_results/search_result_screen.dart';
import 'package:food_recipe_app/widgets/loading_widget.dart';
import 'package:food_recipe_app/validator/url_validator.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_recipe_app/screens/authentication_screen/email_signup_page.dart';
import 'package:food_recipe_app/main.dart';
import 'package:food_recipe_app/repo/get_recipe_by_ingredients.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final SearchPageCubit _searchPageCubit;
  late final TextEditingController _searchController;
  bool _isAdvancedSearchEnabled = false;

  @override
  void initState() {
    super.initState();
    _searchPageCubit = SearchPageCubit(RecipeRepository());
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isAnonymous = user?.isAnonymous ?? true;

    return BlocProvider(
      create: (_) => _searchPageCubit,
      child: BlocListener<SearchPageCubit, SearchPageState>(
        listener: (context, state) {
          if (_searchController.text != state.searchText) {
            _searchController.text = state.searchText;
            _searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: _searchController.text.length),
            );
          }
        },
        child: BlocBuilder<SearchPageCubit, SearchPageState>(
          builder: (context, state) {
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.0)),
              child: Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        backgroundColor: Colors.white,
                        floating: true,
                        pinned: true,
                        title: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: state.isAdvancedSearchEnabled
                                      ? "Enter ingredients, separated by commas"
                                      : "Search Recipes..",
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.search,
                                        color: Colors.redAccent),
                                    onPressed: () {
                                      if (state.isAdvancedSearchEnabled) {
                                        _searchPageCubit
                                            .textChange(state.searchText);
                                      } else {
                                        _searchPageCubit
                                            .textChange(state.searchText);
                                      }
                                    },
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 20),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 2,
                                      style: BorderStyle.solid,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 1,
                                      style: BorderStyle.solid,
                                      color: Colors.black.withOpacity(.5),
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onChanged: (value) {
                                  _searchPageCubit.textChange(value);
                                },
                                onSubmitted: (v) {
                                  if (isAnonymous) {
                                    showGuestOverlay(context);
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => BlocProvider(
                                          create: (context) =>
                                              SearchResultsBloc(),
                                          child: SearchResults(
                                            id: v,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.filter_alt,
                                  color: Colors.redAccent),
                              onPressed: () => _showFilterDrawer(context),
                            ),
                          ],
                        ),
                      ),
                      if (state.isAdvancedSearchEnabled)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              spacing: 8.0,
                              children: state.ingredients
                                  .map((ingredient) => Chip(
                                        label: Text(ingredient),
                                        onDeleted: () {
                                          _searchPageCubit
                                              .removeIngredient(ingredient);
                                        },
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      if (isAnonymous)
                        SliverToBoxAdapter(
                          child: Stack(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25.0, vertical: 20),
                                child: Text(
                                  "Most Recent Searches by People",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Wrap(
                                  alignment: WrapAlignment.start,
                                  children: [
                                    ChipWidget("Baking"),
                                    ChipWidget("Vegetarian"),
                                    ChipWidget("Sauces"),
                                    ChipWidget("Meat"),
                                    ChipWidget("Turkey"),
                                    ChipWidget("Chicken"),
                                    ChipWidget("Sausages"),
                                    ChipWidget("Mince"),
                                    ChipWidget("Burgers"),
                                    ChipWidget("Pasta"),
                                    ChipWidget("Noodles"),
                                    ChipWidget("Pizza"),
                                    ChipWidget("Soups"),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25.0, vertical: 10),
                                child: Text(
                                  "Recipes by Categories",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const CategoryTile(
                                  text: "Main course",
                                  image:
                                      "https://images.unsplash.com/photo-1559847844-5315695dadae?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=740&q=80"),
                              const CategoryTile(
                                  text: "Side-dish",
                                  image:
                                      "https://images.unsplash.com/photo-1534938665420-4193effeacc4?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=751&q=80"),
                              const CategoryTile(
                                  text: "Dessert",
                                  image:
                                      "https://images.unsplash.com/photo-1587314168485-3236d6710814?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=670&q=80"),
                              const CategoryTile(
                                  text: "Appetizer",
                                  image:
                                      "https://images.unsplash.com/photo-1541529086526-db283c563270?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80"),
                              const CategoryTile(
                                text: "Salad",
                                image:
                                    "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80",
                              ),
                              const CategoryTile(
                                text: "Bread",
                                image:
                                    "https://images.unsplash.com/photo-1509440159596-0249088772ff?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=752&q=80",
                              ),
                              const CategoryTile(
                                text: "Breakfast",
                                image:
                                    "https://images.unsplash.com/photo-1525351484163-7529414344d8?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80",
                              ),
                              const CategoryTile(
                                text: "Soup",
                                image:
                                    "https://images.unsplash.com/photo-1547592166-23ac45744acd?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=751&q=80",
                              ),
                              const CategoryTile(
                                text: "Beverage",
                                image:
                                    "https://images.unsplash.com/photo-1595981267035-7b04ca84a82d?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
                              ),
                              const CategoryTile(
                                text: "Sauce",
                                image:
                                    "https://images.unsplash.com/photo-1472476443507-c7a5948772fc?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
                              ),
                              const CategoryTile(
                                text: "Marinade",
                                image:
                                    "https://images.unsplash.com/photo-1598511757337-fe2cafc31ba0?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
                              ),
                              const CategoryTile(
                                text: "Fingerfood",
                                image:
                                    "https://images.unsplash.com/photo-1605333396915-47ed6b68a00e?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
                              ),
                              const CategoryTile(
                                text: "Snack",
                                image:
                                    "https://images.unsplash.com/photo-1599490659213-e2b9527bd087?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
                              ),
                              const CategoryTile(
                                text: "Drink",
                                image:
                                    "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=334&q=80",
                              ),
                              Container(
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'You are logged in as a guest.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      ElevatedButton(
                                        onPressed: () {
                                          showGuestOverlay(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                        ),
                                        child: const Text('Create an Account'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (state.status == Status.success &&
                          state.searchList.isNotEmpty)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return SearchAutoCompleteTile(
                                  list: state.searchList[index]);
                            },
                            childCount: state.searchList.length,
                          ),
                        )
                      else if (state.status == Status.loading)
                        const SliverFillRemaining(
                          child: Center(child: LoadingWidget()),
                        )
                      else
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25.0, vertical: 20),
                                child: Text(
                                  "Most Recent Searches by People",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Wrap(
                                  alignment: WrapAlignment.start,
                                  children: [
                                    ChipWidget("Baking"),
                                    ChipWidget("Vegetarian"),
                                    ChipWidget("Sauces"),
                                    ChipWidget("Meat"),
                                    ChipWidget("Turkey"),
                                    ChipWidget("Chicken"),
                                    ChipWidget("Sausages"),
                                    ChipWidget("Mince"),
                                    ChipWidget("Burgers"),
                                    ChipWidget("Pasta"),
                                    ChipWidget("Noodles"),
                                    ChipWidget("Pizza"),
                                    ChipWidget("Soups"),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25.0, vertical: 10),
                                child: Text(
                                  "Recipes by Categories",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const CategoryTile(
                                  text: "Main course",
                                  image:
                                      "https://images.unsplash.com/photo-1559847844-5315695dadae?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=740&q=80"),
                              const CategoryTile(
                                  text: "Side-dish",
                                  image:
                                      "https://images.unsplash.com/photo-1534938665420-4193effeacc4?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=751&q=80"),
                              const CategoryTile(
                                  text: "Dessert",
                                  image:
                                      "https://images.unsplash.com/photo-1587314168485-3236d6710814?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=670&q=80"),
                              const CategoryTile(
                                  text: "Appetizer",
                                  image:
                                      "https://images.unsplash.com/photo-1541529086526-db283c563270?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80"),
                              const CategoryTile(
                                text: "Salad",
                                image:
                                    "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80",
                              ),
                              const CategoryTile(
                                text: "Bread",
                                image:
                                    "https://images.unsplash.com/photo-1509440159596-0249088772ff?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=752&q=80",
                              ),
                              const CategoryTile(
                                text: "Breakfast",
                                image:
                                    "https://images.unsplash.com/photo-1525351484163-7529414344d8?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80",
                              ),
                              const CategoryTile(
                                text: "Soup",
                                image:
                                    "https://images.unsplash.com/photo-1547592166-23ac45744acd?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=751&q=80",
                              ),
                              const CategoryTile(
                                text: "Beverage",
                                image:
                                    "https://images.unsplash.com/photo-1595981267035-7b04ca84a82d?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
                              ),
                              const CategoryTile(
                                text: "Sauce",
                                image:
                                    "https://images.unsplash.com/photo-1472476443507-c7a5948772fc?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
                              ),
                              const CategoryTile(
                                text: "Marinade",
                                image:
                                    "https://images.unsplash.com/photo-1598511757337-fe2cafc31ba0?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
                              ),
                              const CategoryTile(
                                text: "Fingerfood",
                                image:
                                    "https://images.unsplash.com/photo-1605333396915-47ed6b68a00e?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
                              ),
                              const CategoryTile(
                                text: "Snack",
                                image:
                                    "https://images.unsplash.com/photo-1599490659213-e2b9527bd087?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
                              ),
                              const CategoryTile(
                                text: "Drink",
                                image:
                                    "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=334&q=80",
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFilterDrawer(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width *
                  0.7, // Adjust width as needed
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter Options',
                            style: GoogleFonts.chivo(
                              textStyle: const TextStyle(
                                fontSize: 25.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isAdvancedSearchEnabled =
                                !_isAdvancedSearchEnabled;
                          });
                          _searchPageCubit.toggleAdvancedSearch();
                          if (_isAdvancedSearchEnabled) {
                            _searchPageCubit.emit(_searchPageCubit.state
                                .copyWith(ingredients: []));
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isAdvancedSearchEnabled
                              ? Colors.orange.withOpacity(0.5)
                              : Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Search with ingredients',
                            style: TextStyle(
                              color: _isAdvancedSearchEnabled
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void showGuestOverlay(BuildContext context) {
  showMaterialModalBottomSheet(
    context: context,
    builder: (context) => SingleChildScrollView(
      controller: ModalScrollController.of(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 20.0),
            const Text(
              'You are currently logged in as a guest.',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'To access all features and personalize your experience, please create an account.',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Future.delayed(
                  const Duration(seconds: 1),
                  () {
                    navKey.currentState?.pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const EmailSignUp()),
                      (route) => false,
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Create an Account',
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class CategoryTile extends StatelessWidget {
  final String text;
  final String image;
  const CategoryTile({super.key, required this.text, required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: DelayedDisplay(
        delay: const Duration(microseconds: 600),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(boxShadow: const [
            BoxShadow(
              offset: Offset(-2, -2),
              blurRadius: 12,
              color: Color.fromRGBO(0, 0, 0, 0.05),
            ),
            BoxShadow(
              offset: Offset(2, 2),
              blurRadius: 5,
              color: Color.fromRGBO(0, 0, 0, 0.10),
            )
          ], borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: ListTile(
            leading: Container(
              width: 100,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: CachedNetworkImage(
                memCacheWidth: 262,
                memCacheHeight: 147,
                imageUrl: image,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, imgDownloadProgress) =>
                    CircularProgressIndicator(
                        value: imgDownloadProgress.progress,
                        strokeWidth: 0.2,
                        strokeAlign: 0.0,
                        color: Colors.orange),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                //cacheManager: GlobalCacheManager.customCacheManager,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => SearchResultsBloc(),
                    child: SearchResults(
                      id: text,
                    ),
                  ),
                ),
              );
            },
            title: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.arrow_right_alt),
          ),
        ),
      ),
    );
  }
}

class SearchAutoCompleteTile extends StatefulWidget {
  final SearchAutoComplete list;
  const SearchAutoCompleteTile({
    super.key,
    required this.list,
  });

  @override
  _SearchAutoCompleteTileState createState() => _SearchAutoCompleteTileState();
}

class _SearchAutoCompleteTileState extends State<SearchAutoCompleteTile> {
  late Future<bool> _validationFuture;

  @override
  void initState() {
    super.initState();
    _validationFuture = validateURL(widget.list.image);
  }

  @override
  Widget build(BuildContext context) {
    //print(widget.list.image);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              offset: Offset(-2, -2),
              blurRadius: 12,
              color: Color.fromRGBO(0, 0, 0, 0.05),
            ),
            BoxShadow(
              offset: Offset(2, 2),
              blurRadius: 5,
              color: Color.fromRGBO(0, 0, 0, 0.10),
            )
          ],
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: FutureBuilder<bool>(
          future: _validationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                strokeWidth: 0.2,
                strokeAlign: 0.0,
                color: Colors.orange,
              );
            } else if (snapshot.hasError) {
              return const Icon(Icons.error);
            } else if (snapshot.hasData && snapshot.data!) {
              // if the URL is valid, then proceed to load the image
              return ListTile(
                onTap: () {
                  // Check if the image URL is valid before displaying the image
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => RecipeInfoBloc(),
                        child: RecipeInfo(
                          id: widget.list.id,
                        ),
                      ),
                    ),
                  );
                },
                leading: Container(
                  width: 100,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade600,

                    //cacheManager: GlobalCacheManager.customCacheManager,
                  ),
                  child: CachedNetworkImage(
                    memCacheWidth: 262,
                    memCacheHeight: 147,
                    imageUrl: widget.list.image,
                    fit: BoxFit.cover,
                    cacheManager: CacheManager(
                      Config(
                        'customCacheKey',
                        maxNrOfCacheObjects: 100,
                        stalePeriod: const Duration(minutes: 5),
                      ),
                    ),
                    progressIndicatorBuilder: (context, url,
                            imgDownloadProgress) =>
                        CircularProgressIndicator(
                            value: imgDownloadProgress.progress,
                            strokeWidth: 0.2,
                            strokeAlign: 0.0,
                            color: Colors.orange),
                    errorWidget: (context, url, error) {
                      return const Icon(Icons.error); // Display erorr icon
                    },
                    // image: DecorationImage(
                    //   fit: BoxFit.cover,
                    //   image: CachedNetworkImageProvider(widget.list.image),
                    // ),
                  ),
                ),
                title: Text(
                  widget.list.name.toUpperCase(),
                  style: GoogleFonts.workSans(
                    textStyle: const TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            } else {
              // Handle invalid URL
              return ListTile(
                title: Text(
                  "Failed to load",
                  style: GoogleFonts.workSans(
                    textStyle: const TextStyle(
                      fontSize: 15.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
