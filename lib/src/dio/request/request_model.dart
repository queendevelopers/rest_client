abstract class IRequestModel {
  Map<String, dynamic> toJson();
}

class BaseRequestModel implements IRequestModel {
  @override
  Map<String, dynamic> toJson() => {};
}
