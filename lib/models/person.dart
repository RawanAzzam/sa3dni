import 'dart:async';

import 'category.dart';

class Person{
   late String name;
   late String  address;
   late Category category;
   late String phoneNumber;
   late String email;
   late String id;
   late String image;

   String type = '';
   StreamController<String> controller = StreamController<String>();
   Person.withNoParameter();
   Person({required this.id});

   Person.withSingInInfo({required this.email });

   Person.withPatientInfo({required this.name ,
     required this.email ,
     required this.category ,
     required this.id});


   Person.withPar({required this.name,
     required this.phoneNumber ,
     required this.address,
     required this.category,
   required this.email,
   required this.id});



   void setEmail(String email){
     this.email = email;
   }



   void setType(String type){
     this.type = type;
    Type;
   }


   Stream<String?> get Type{
     return controller.stream;
   }
}