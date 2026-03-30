import 'package:flutter/material.dart';

import '../models/tenant_order_details.dart';
import '../models/tenant_order_summary.dart';

class TenantOrderUi {
  static String actionLabel(String key) {
    switch (key) {
      case 'confirm_order':
        return 'Confirm';
      case 'start_preparing':
        return 'Start Preparing';
      case 'mark_ready_for_pickup':
        return 'Mark Ready';
      case 'mark_out_for_delivery':
        return 'Out for Delivery';
      case 'mark_completed':
        return 'Complete';
      case 'cancel_order':
        return 'Cancel';
      default:
        return key.replaceAll('_', ' ');
    }
  }

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.deepPurple;
      case 'ready_for_pickup':
      case 'out_for_delivery':
        return Colors.teal;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return const Color(0xFF6B7280);
    }
  }

  static String timelineStatusLabel(String status, String orderType) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'ready_for_pickup':
        return 'Ready for Pickup';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'completed':
        return orderType == 'delivery' ? 'Delivered' : 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  static String? historySubtitle(TenantOrderHistoryItem item) {
    if ((item.reasonCode ?? '').isNotEmpty) {
      return 'Reason: ${reasonLabel(item.reasonCode!)}';
    }
    if ((item.actionKey ?? '').isNotEmpty) {
      return actionLabel(item.actionKey!);
    }
    return null;
  }

  static String reasonLabel(String reason) {
    switch (reason) {
      case 'out_of_stock':
        return 'Out of stock';
      case 'store_closed':
        return 'Store closed';
      case 'unable_to_fulfill':
        return 'Unable to fulfill';
      case 'customer_request':
        return 'Customer request';
      case 'other':
        return 'Other';
      default:
        return reason.replaceAll('_', ' ');
    }
  }

  static String summaryStatusLabel(TenantOrderSummary order) {
    return timelineStatusLabel(order.status, order.orderType);
  }
}
