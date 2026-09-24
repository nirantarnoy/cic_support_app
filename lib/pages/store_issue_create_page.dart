import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/product_group_menu.dart';
import 'package:flutter_cic_support/models/products.dart';
import 'package:flutter_cic_support/pages/store_issue_cart_page.dart';
import 'package:flutter_cic_support/providers/store_issue_product.dart';
import 'package:flutter_cic_support/providers/store_issue_productgroup.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cic_support/pages/store_issue_history_page.dart' as flutter_cic_support_history;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
class StoreIssueCreatePage extends StatefulWidget {
  @override
  _StoreIssueCreatePageState createState() => _StoreIssueCreatePageState();
}

class _StoreIssueCreatePageState extends State<StoreIssueCreatePage> {
  final TextEditingController _searchController = TextEditingController();

  String _translateCategory(String categoryName) {
    Map<String, String> translations = {
      '': 'ทั้งหมด',
      'ALL': 'ทั้งหมด',
      'OFFICE SUPPLY': 'อุปกรณ์สำนักงาน',
      'OFFICE SUPPLIES': 'อุปกรณ์สำนักงาน',
      'SAFETY': 'อุปกรณ์เซฟตี้',
      'CLEANING': 'อุปกรณ์ทำความสะอาด',
      'TOOLS': 'เครื่องมือช่าง',
      'CHEMICAL': 'สารเคมี',
      'CONSUMABLE': 'วัสดุสิ้นเปลือง',
      'CONSUMABLES': 'วัสดุสิ้นเปลือง',
      'ELECTRICAL': 'อุปกรณ์ไฟฟ้า',
      'MEDICAL': 'เวชภัณฑ์',
      'PACKAGING': 'บรรจุภัณฑ์',
      'SPARE PARTS': 'อะไหล่',
      'SPAREPART': 'อะไหล่',
      'FACTORY SUPPLIES': 'ของใช้ในโรงงาน',
      'IT': 'อุปกรณ์ไอที',
      'HARDWARE': 'ฮาร์ดแวร์',
      'STATIONERY': 'เครื่องเขียน',
    };
    String key = categoryName.trim().toUpperCase();
    if (translations.containsKey(key)) {
      return translations[key]!;
    }
    return categoryName.trim().isEmpty ? 'ทั้งหมด' : categoryName;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProductgroup();
      _fetchProduct();
    });
  }

  Future _fetchProductgroup() async {
    await Provider.of<ProductgroupData>(context, listen: false).fetchProductgroupmain();
  }

  Future _fetchProduct() async {
    await Provider.of<ProductData>(context, listen: false).fetchProductDataMain('');
  }

  void _searchProduct(String value) async {
    EasyLoading.show(status: 'กำลังค้นหา...');
    await Provider.of<ProductData>(context, listen: false).fetchProductDataBySearchMain(value);
    EasyLoading.dismiss();
  }
  
  void _fetchDatabyCategory(String category) async {
    EasyLoading.show(status: 'กำลังโหลด...', maskType: EasyLoadingMaskType.black);
    await Provider.of<ProductData>(context, listen: false).fetchProductDataMain(category);
    EasyLoading.dismiss();
  }

  void _showAddProductDialog(Products product) {
    TextEditingController qtyController = TextEditingController(text: "1");
    
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            double price = double.tryParse(product.price.toString().replaceAll(',', '')) ?? 0;
            String qtyText = qtyController.text.replaceAll(',', '');
            double qty = double.tryParse(qtyText) ?? 0;
            double total = price * qty;
            
            var formatter = NumberFormat('#,##,##0.00');
            var qtyFormatter = NumberFormat('#,##,##0.##');
            double onhand = double.tryParse(product.onhand.toString().replaceAll(',', '')) ?? 0;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: Text('ระบุจำนวนที่ต้องการเบิก', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${product.name}', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 10),
                  Text('ราคาต่อหน่วย: ${formatter.format(price)} บาท', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  Text('ยอดคงเหลือ: ${qtyFormatter.format(onhand)} ${product.unit_name}', style: TextStyle(fontSize: 12, color: Colors.blue[700])),
                  SizedBox(height: 15),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'จำนวน',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                    onChanged: (val) {
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 10),
                  Text('รวมเป็นเงิน: ${formatter.format(total)} บาท', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('ยกเลิก', style: TextStyle(color: Colors.grey[600]))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                     double inputQty = double.tryParse(qtyController.text.replaceAll(',', '')) ?? 0;
                     if (inputQty <= 0) return;
                     
                     double currentInCart = 0;
                     var cartItems = Provider.of<ProductData>(context, listen: false).orderItems;
                     for (var c in cartItems) {
                        if (c.id == product.id) {
                            currentInCart += double.tryParse(c.qty.replaceAll(',', '')) ?? 0;
                        }
                     }

                     if (currentInCart + inputQty > onhand) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('จำนวนที่เบิกรวมในตะกร้ามากกว่ายอดคงเหลือ'), backgroundColor: Colors.red));
                        return;
                     }

                     if (Provider.of<ProductData>(context, listen: false).countCartItem() >= 10 && currentInCart == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("คุณสามารถเพิ่มได้ไม่เกิน 10 รายการ"), backgroundColor: Colors.red));
                        return;
                     }

                     EasyLoading.show(status: 'กำลังเพิ่ม...');
                     Provider.of<ProductData>(context, listen: false).addCartItem(
                        product.id,
                        product.name,
                        qtyController.text.replaceAll(',', ''),
                        product.price,
                        product.unit_name,
                        onhand: product.onhand.toString(),
                     );
                     EasyLoading.dismiss();
                     
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                       content: Row(
                         children: <Widget>[
                           Icon(Icons.check_circle, color: Colors.white),
                           SizedBox(width: 10),
                           Text("เพิ่มรายการสินค้าแล้ว", style: TextStyle(color: Colors.white)),
                         ],
                       ),
                       backgroundColor: Colors.green,
                     ));
                     
                     Navigator.of(ctx).pop();
                  },
                  child: Text('เพิ่มลงตะกร้า', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                ),
              ]
            );
          }
        );
      }
    );
  }

  Future<void> _scanQR() async {
    try {
      var result = await BarcodeScanner.scan();
      String barcodeScanRes = result.rawContent;
          
      if (barcodeScanRes != '-1' && barcodeScanRes.isNotEmpty) {
        EasyLoading.show(status: 'กำลังเชื่อมต่อตู้ Kiosk...');
        final pref = await SharedPreferences.getInstance();
        final String? empCode = pref.getString('emp_code');
        final String? jwtToken = pref.getString('token');

        final response = await http.post(
          Uri.parse('https://api.cicsupports.com/api/kiosk/scan-qr'),
          headers: {
            'Content-Type': 'application/json',
            if (jwtToken != null) 'Authorization': 'Bearer $jwtToken',
          },
          body: json.encode({
            'token': barcodeScanRes,
            'emp_code': empCode,
          }),
        ).timeout(const Duration(seconds: 10));

        EasyLoading.dismiss();

        if (response.statusCode == 200) {
          final resData = json.decode(response.body);
          if (resData['status'] == true) {
             showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('สำเร็จ!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                content: Text('เชื่อมต่อตู้ Kiosk สำเร็จแล้ว กรุณาทำรายการต่อที่หน้าตู้ Kiosk'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('ตกลง', style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              )
            );
          } else {
            EasyLoading.showError('รหัสไม่ถูกต้องหรือหมดอายุ');
          }
        } else {
          EasyLoading.showError('เกิดข้อผิดพลาดในการเชื่อมต่อ (HTTP ${response.statusCode})');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('เกิดข้อผิดพลาด: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('เบิกสินค้า', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[700],
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: _scanQR,
            tooltip: 'สแกนคิวอาร์โค้ดตู้ Kiosk',
          ),
          IconButton(
            icon: Icon(Icons.history_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const flutter_cic_support_history.StoreissueHistoryPage()));
            },
            tooltip: 'ประวัติการเบิก',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.blue[700],
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "ค้นหาสินค้า...",
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.blue[400]),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, size: 20, color: Colors.grey[400]),
                    onPressed: () {
                      _searchController.clear();
                      _searchProduct('');
                    },
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  isCollapsed: true,
                ),
                onSubmitted: _searchProduct,
              ),
            ),
          ),
          
          // Category Menu
          Container(
            height: 60,
            color: Colors.white,
            child: Consumer<ProductgroupData>(
              builder: (context, productGroupData, _) {
                var menu = productGroupData.listproductgroup;
                if (menu.isEmpty) {
                  return Center(child: Text('กำลังโหลดหมวดหมู่...'));
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  scrollDirection: Axis.horizontal,
                  itemCount: menu.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        for (var element in menu) {
                          element.isactive = (element.name == menu[index].name);
                        }
                        setState(() {});
                        _fetchDatabyCategory(menu[index].name);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: menu[index].isactive ? Colors.blue[50] : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: menu[index].isactive ? Colors.blue : Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _translateCategory(menu[index].name),
                          style: TextStyle(
                            fontWeight: menu[index].isactive ? FontWeight.bold : FontWeight.normal,
                            color: menu[index].isactive ? Colors.blue[700] : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Product Grid
          Expanded(
            child: Consumer<ProductData>(
              builder: (context, productData, _) {
                var products = productData.listproduct;
                if (productData.is_loading) {
                  return Center(child: CircularProgressIndicator());
                }
                if (products.isEmpty) {
                  return Center(child: Text('ไม่พบสินค้า', style: TextStyle(color: Colors.grey[500])));
                }
                
                // Determine crossAxisCount based on screen width
                double screenWidth = MediaQuery.of(context).size.width;
                int crossAxisCount = screenWidth > 800 ? 5 : (screenWidth > 600 ? 4 : 2);
                
                var priceFormatter = NumberFormat('#,##,##0.00');

                return GridView.builder(
                  padding: EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var product = products[index];
                    String prefix = (product.id != null && product.id.toString().length >= 2) ? product.id.toString().substring(0, 2) : '';
                    var restrict_product = ['21', '22', '31', '32'];
                    bool isRestricted = restrict_product.contains(prefix);
                    
                    double priceVal = double.tryParse(product.price.toString().replaceAll(',', '')) ?? 0;
                    double onhandVal = double.tryParse(product.onhand.toString().replaceAll(',', '')) ?? 0;

                    return GestureDetector(
                      onTap: () {
                        if (onhandVal <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('จำนวนคงเหลือไม่เพียงพอ'), backgroundColor: Colors.red));
                        } else {
                          _showAddProductDialog(product);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: Offset(0, 4))],
                          border: Border.all(color: isRestricted ? Colors.orange.withOpacity(0.5) : Colors.transparent, width: 1.5)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isRestricted ? Colors.orange[50] : Colors.blue[50],
                                        borderRadius: BorderRadius.circular(6)
                                      ),
                                      child: Text(product.id.toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isRestricted ? Colors.orange[800] : Colors.blue[800])),
                                    ),
                                    SizedBox(height: 8),
                                    Expanded(
                                      child: Text(
                                        product.name.toString(),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.2),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '฿${priceFormatter.format(priceVal)}',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              decoration: BoxDecoration(
                                color: onhandVal > 0 ? Colors.green[50] : Colors.red[50],
                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 14, color: onhandVal > 0 ? Colors.green[700] : Colors.red[700]),
                                  SizedBox(width: 4),
                                  Text(
                                    'คงเหลือ ${product.onhand} ${product.unit_name}',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: onhandVal > 0 ? Colors.green[700] : Colors.red[700]),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            )
          )
        ],
      ),
      floatingActionButton: Consumer<ProductData>(
        builder: (context, productData, child) {
          int cartCount = productData.countCartItem();
          if (cartCount == 0) return SizedBox.shrink();
          
          return FloatingActionButton.extended(
            backgroundColor: Colors.blue[700],
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.shopping_cart, color: Colors.white),
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(cartCount.toString(), style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
            label: Text('ดูตะกร้าเบิกของ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => StoreIssueCartPage()));
            },
          );
        },
      ),
    );
  }
}
