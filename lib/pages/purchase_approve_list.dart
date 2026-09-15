import 'package:flutter/material.dart';
import 'package:flutter_cic_support/pages/purchase_approve_detail.dart';
import 'package:flutter_cic_support/providers/purchase_approve.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PurchaseApproveListPage extends StatefulWidget {
  const PurchaseApproveListPage({Key? key}) : super(key: key);

  @override
  State<PurchaseApproveListPage> createState() => _PurchaseApproveListPageState();
}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PurchaseApproveProvider>(context, listen: false).fetchPendingList();
    });
  }

  Future<void> _refreshData() async {
    await Provider.of<PurchaseApproveProvider>(context, listen: false).fetchPendingList();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'รายการรออนุมัติขอซื้อ',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Prompt',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PurchaseApproveProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF8E24AA)));
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Text(provider.errorMessage, style: const TextStyle(fontFamily: 'Prompt', color: Colors.red)),
            );
          }

          final _requests = provider.pendingList;

          return _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shopping_cart_checkout_rounded, size: 48, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "ไม่พบรายการรออนุมัติขอซื้อ",
                        style: TextStyle(fontFamily: 'Prompt', fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: const Color(0xFF8E24AA),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final item = _requests[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PurchaseApproveDetailPage(
                          requestData: item,
                        ),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8E24AA).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shopping_cart_outlined,
                                color: Color(0xFF8E24AA),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item['pr_no'] ?? '',
                                        style: const TextStyle(
                                          fontFamily: 'Prompt',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF7E36).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          item['status'],
                                          style: const TextStyle(
                                            fontFamily: 'Prompt',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFF7E36),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${item['requestor_name'] ?? ''} (${item['req_dept'] ?? ''})',
                                    style: const TextStyle(
                                      fontFamily: 'Prompt',
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            item['request_date'] ?? '',
                                            style: const TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          if (item['has_attachment'] == true) ...[
                                            const Icon(Icons.attach_file_rounded, size: 14, color: Colors.blue),
                                            const SizedBox(width: 8),
                                          ],
                                          Text(
                                            '฿${formatter.format(item['total_amount'] ?? 0)}',
                                            style: const TextStyle(
                                              fontFamily: 'Prompt',
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F9B73),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                    },
                  ),
                );
        },
      ),
    );
  }
}
