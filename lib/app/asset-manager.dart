class AssetManager{

  /// [iconFile] is used for getting the a particular icon from the asset directory. 
  static String iconFile({required String name}){
    return "assets/icons/$name.png";
  }

  /// [svgFile] is used for getting the a particular image from the asset directory. 
  static String svgFile({required String name}){
    return "assets/icons/$name.svg";
  }

  /// [imageFile] is used for getting the a particular image from the asset directory. 
  static String imageFile({required String name}){
    return "assets/images/$name.jpg";
  }

  /// [lottieFile] is used for getting the a particular lottie from the asset directory. 
  static String lottieFile({required String name}){
    return "assets/lottie/$name.json";
  }
}