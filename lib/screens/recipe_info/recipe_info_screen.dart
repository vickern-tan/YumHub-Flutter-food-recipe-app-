import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_recipe_app/widgets/loading_widget.dart';
import '../random_recipe/widgets/recipe_info_success_widget.dart';

import 'bloc/recipe_info_bloc.dart';

class RecipeInfo extends StatefulWidget {
  final String id;
  const RecipeInfo({Key? key, required this.id}) : super(key: key);

  @override
  State<RecipeInfo> createState() => _RecipeInfoState();
}

class _RecipeInfoState extends State<RecipeInfo> {
  late final RecipeInfoBloc bloc;
  @override
  void initState() {
    bloc = BlocProvider.of<RecipeInfoBloc>(context);
    bloc.add(LoadRecipeInfo(widget.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<RecipeInfoBloc, RecipeInfoState>(
          builder: (context, state) {
            if (state is RecipeInfoLoadState) {
              return const Center(child: LoadingWidget());
            } else if (state is RecipeInfoSuccesState) {
              ///Displaying Recipe Info Widget
              return RacipeInfoWidget(
                equipment: state.equipment,
                info: state.recipe,
                nutrient: state.nutrient,
                similarlist: state.similar,
                recipeId: state.recipe.id.toString(),
              );
            } else if (state is RecipeInfoErrorState) {
              ///On Displaying Error
              return const Center(
                child: Text("An error occured... Please try again"),
              );
            } else {
              return const Center(
                child: Text("Nothing happens"),
              );
            }
          },
        ),
      ),
    );
  }
}
