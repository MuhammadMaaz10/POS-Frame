import 'package:flutter/material.dart';
import 'package:frame_virtual_fiscilation/constants/app_constants.dart';
import 'package:frame_virtual_fiscilation/presentation/add_item/controller/add_item_controller.dart';
import 'package:frame_virtual_fiscilation/presentation/add_item/edit_item_screen.dart';
import 'package:frame_virtual_fiscilation/presentation/home_screen/controller/home_screen_controller.dart';
import 'package:frame_virtual_fiscilation/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../constants/app_color.dart';
import '../../../constants/app_images.dart';
import '../../../local_storage/item_model.dart';
import '../../../widgets/TextField.dart';
import '../../../widgets/custom_list_tile.dart';

// class ItemsScreen extends StatefulWidget {
//    ItemsScreen({
//     super.key,
//   });
//
//   @override
//   State<ItemsScreen> createState() => _ItemsScreenState();
// }
//
// class _ItemsScreenState extends State<ItemsScreen> {
//   final TextEditingController _controller = TextEditingController();
//
//
//
//    List<ItemModel> itemList = [];
//         // All items from Hive
//    List<ItemModel> filteredList = [];
//     // Filtered list based on search
//    @override
//    void initState() {
//      super.initState();
//      loadItems();
//      _controller.addListener(() {
//        filterItems(_controller.text);
//      });
//    }
//
//    void loadItems() {
//      final box = Hive.box<ItemModel>('items');
//      itemList = box.values.toList();
//      filteredList = List.from(itemList); // initially show all
//      setState(() {});
//    }
//
//    void filterItems(String query) {
//      if (query.isEmpty) {
//        filteredList = List.from(itemList);
//      } else {
//        filteredList = itemList
//            .where((item) =>
//            item.itemName.toLowerCase().contains(query.toLowerCase()))
//            .toList();
//      }
//      setState(() {});
//    }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Container(
//       margin: const EdgeInsets.fromLTRB(18, 18, 18, 10),
//       child: Column(
//         children: [
//           CustomTextField(
//               controller: _controller,
//               hintText: "Search",
//               prefixIcon: Icons.search,
//               borderColor: Colors.transparent,
//               selectedBorderColor: AppColors.buttonClr
//           ),
//           20.ht,
//           Expanded(
//             child: ListView.separated(
//               itemBuilder: (context, index) {
//
//
//                 final item = filteredList[index];
//
//                 return
//
//
//
//
//
//
//
//                   filteredList.isNotEmpty ?
//
//                   ItemsCustomListTile(
//                   titleText:item.itemName,
//                   subTitleText: item.itemCategory,
//                   amount: item.unitPrice,
//                   imageUrl: null,
//                 ) : Text('No items found');
//               },
//               itemCount: filteredList.length,
//               shrinkWrap: true,
//               separatorBuilder: (context, index) => SizedBox(height: 10),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


class ItemsScreen extends StatelessWidget {
  final  homeController = Get.put(HomeScreenController());
  final itemController = Get.put(AddItemController());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Column(
        children: [
          CustomTextField(
              controller: homeController.searchItemController,
              hintText: "Search",
              prefixIcon: Icons.search,
              borderColor: Colors.transparent,
              selectedBorderColor: AppColors.buttonClr),
          20.ht,
          Expanded(
            child: Obx(() {
              if (homeController.filteredItemList.isEmpty) {
                return Center(child: Text('No items found'));
              }
              return ListView.separated(
                itemBuilder: (context, index) {
                  final item = homeController.filteredItemList[index];
                  return ItemsCustomListTile(
                    onTap: () {
                      itemController.editItemIndex=index;
                      itemController.editNameController.text = item.itemName.toString() ?? "";
                      itemController.editHsCodeController.text = item.hsCode.toString() ?? "";
                      itemController.editPriceController.text = item.unitPrice.toString() ?? "";
                      itemController.editCategoryController.text = item.itemCategory.toString() ?? "";
                      itemController.editDescriptionController.text = item.itemDescription.toString() ?? "";
                      itemController.editVatCategoryController.text = item.vatCategory.toString() ?? "";
                      Get.to(EditItemScreen());
                    },
                    titleText: item.itemName,
                    subTitleText: item.itemCategory,
                    amount: item.unitPrice,
                    imageUrl: null,
                  );
                },
                itemCount: homeController.filteredItemList.length,
                separatorBuilder: (context, index) => SizedBox(height: 10),
              );
            }),
          ),
        ],
      ),
    );
  }
}
