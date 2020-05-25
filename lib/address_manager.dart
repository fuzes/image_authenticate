import 'dart:math';

class AddressManager {
  List<String> addressList = [
    "서울특별시 종로구",
    "서울특별시 중구",
    "서울특별시 용산구",
    "서울특별시 성동구",
    "서울특별시 광진구",
    "서울특별시 동대문구",
    "서울특별시 중랑구",
    "서울특별시 성북구",
    "서울특별시 강북구",
    "서울특별시 도봉구",
    "서울특별시 노원구",
    "서울특별시 은평구",
    "서울특별시 서대문구",
    "서울특별시 마포구",
    "서울특별시 양천구",
    "서울특별시 강서구",
    "서울특별시 구로구",
    "서울특별시 금천구",
    "서울특별시 영등포구",
    "서울특별시 동작구",
    "서울특별시 강남구",
    "서울특별시 송파구",
    "서울특별시 강동구"
  ];

  List<String> makeSelectableList(address) {
    var list = addressList;
    list.remove(address);
    list.shuffle();
    var selectableList = list.sublist(0, 4);
    selectableList.add(address);
    return selectableList;
  }
}