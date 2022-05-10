
class Post{
  String content;
  DateTime time;
  String image;
  String organizationId;
  String organizationName;
  String organizationImage;
  String privacy;
  Post({required this.organizationId,
         required this.organizationName,
  required this.organizationImage,
  required this.content,
  required this.image,
  required this.time,
  required this.privacy});
}