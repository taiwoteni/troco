
import 'enums.dart';

class AttachmentTypeConvert{
  static AttachmentType convertToEnum({required final String type}){
    switch(type.trim().toLowerCase()){
      case "image":
      return AttachmentType.Image;
      case "video":
      return AttachmentType.Video;
      case "audio":
      return AttachmentType.Audio;
      default:
      return AttachmentType.Document;
    }
  }
}