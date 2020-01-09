// Implements override the inherited classes, like all classes inherit Object and has methods like .toString()
// Implements can be used if you want to create your own implementation of another class or interface. When class a implements class b. All functions defined in class b must be implemented.
//When you're implementing another class, you do not inherit code from the class. You only inherit the type. In Dart you can use the implements keyword with multiple classes or interfaces.
// https://stackoverflow.com/questions/55295782/extends-versus-implements-versus-with

class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  @override
  String toString() {
    return message;
    // return super.toString(); //Instance of HttpException
  }
}
