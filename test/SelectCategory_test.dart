import 'package:sa3dni_app/Home/selectCategory.dart';
import 'package:sa3dni_app/models/category.dart';
import 'package:flutter_test/flutter_test.dart';


Future <void> main() async{
test("Select one Category", ()
{
  var category;
  final tes = SelectCategory(isPatient: true,);
  if (tes.isPatient == true) {
    final result = tes.isPatient == true;
    (category.name = "Smoking") as Category;
    final ExpectedValue = "Smoking";
    expect(result, ExpectedValue);

  }
});


//*****************************************************************************


test("Select one Category", ()
{
  var category;
  final tes = SelectCategory(isPatient: true,);
  if (tes.isPatient == true) {
    final result = tes.isPatient == true;
    (category.name = "Drugs") as Category;
    final ExpectedValue = "Drugs";
    expect(result, ExpectedValue);

  }
});
//*****************************************************************************


test("Select one Category", ()
{
  var category;
  final tes = SelectCategory(isPatient: true,);
  if (tes.isPatient == true) {
    final result = tes.isPatient == true;
    (category.name = "MobilePhone") as Category;
    final ExpectedValue = "MobilePhone";
    expect(result, ExpectedValue);

  }
});
}