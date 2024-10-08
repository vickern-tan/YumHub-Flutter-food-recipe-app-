part of 'random_recipe_bloc.dart';

abstract class RandomRecipeState {}

class RandomRecipeInitial extends RandomRecipeState {}

class RandomRecipeLoadState extends RandomRecipeState {}

class RandomRecipeSuccesState extends RandomRecipeState {
  final Recipe recipe;
  final List<Similar> similar;
  final List<Equipment> equipment;
  final Nutrient nutrient;

  RandomRecipeSuccesState({
    required this.recipe,
    required this.nutrient,
    required this.similar,
    required this.equipment,
  });
}

class RandomRecipeErrorState extends RandomRecipeState {
  final String errorMessage;

  RandomRecipeErrorState(this.errorMessage);
}

class FailureState extends RandomRecipeState {
  final Failure error;

  FailureState({required this.error});
}
