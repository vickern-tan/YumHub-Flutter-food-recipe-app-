import 'package:dio/dio.dart';
import 'package:food_recipe_app/api/api_keys.dart';
import 'package:food_recipe_app/models/failure.dart';
import 'package:food_recipe_app/models/food_type.dart';
import 'package:food_recipe_app/repo/get_recipe_info.dart';

class GetHomeRecipes {
  var key = ApiKey.keys;
  // ignore: non_constant_identifier_names

  final dio = Dio();

  ///Network Calling to get recipes from Spoonacular api
  Future<FoodTypeList> getRecipes(String type, int no) async {
    var url = '$BASE_URL/random?number=$no&tags=$type&apiKey=$key';
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      return FoodTypeList.fromJson(response.data['recipes']);
    } else if (response.statusCode == 401) {
      throw Failure(code: 401, message: response.data['message']);
    } else {
      print(response.statusCode);
      throw Failure(
          code: response.statusCode!, message: response.statusMessage!);
    }
  }
}
