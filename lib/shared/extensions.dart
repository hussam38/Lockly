
extension NonNullString on String? {
  String orEmpty(){
    if(this == null) {
      return "";
    } else {
      return this!;
    }
  }
}

extension NonNullInterger on int?{
  int orZero(){
    if(this == null){
      return 0;
    }else{
      return this!;
    }
  }
}
extension NonNullDouble on double?{
  double orDouble (){
    if(this == null){
      return 0.0;
    }else{
      return this!;
    }
  }
}

extension NonNullBoolean on bool?{
  bool orBool(){
    if(this == null){
      return false;
    }else{
      return this!;
    }
  }
}