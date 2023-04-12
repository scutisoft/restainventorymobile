import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

setSharedPrefBoolUtil(bool value,String key) async{
  SharedPreferences sp=await SharedPreferences.getInstance();
  sp.setBool(key, value);
}
getSharedPrefBoolUtil(String key) async{
  SharedPreferences sp=await SharedPreferences.getInstance();
  return sp.getBool(key)??false;
}

setSharedPrefStringUtil(dynamic value,String key) async{
  SharedPreferences sp=await SharedPreferences.getInstance();
  sp.setString(key, value ==null?"":value.toString());
}
Future<String> getSharedPrefStringUtil(String key) async{
  SharedPreferences sp=await SharedPreferences.getInstance();
  return sp.getString(key)??"";
}

void setSharedPrefListUtil(key, value) async{
  SharedPreferences sp=await SharedPreferences.getInstance();
  sp.setString(key, json.encode(value));
}

getSharedPrefListUtil(key) async{
  SharedPreferences sp=await SharedPreferences.getInstance();
  return json.decode(sp.getString(key)??"");
}