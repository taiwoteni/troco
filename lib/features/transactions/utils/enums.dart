// ignore_for_file: constant_identifier_names

enum Category {
  Personal,
  Merchant,
  Business,
  Company,
}

enum TransactionPurpose { Buying, Selling }

enum TransactionCategory { Product, Service, Virtual }

enum ProductCondition { New, ForeignUsed, NigerianUsed }

enum ProductQuality {Good, Faulty, High, Low}

enum InspectionPeriod { Hour, Day }

enum TransactionStatus {
  /// When buyer has not yet approved. Transaction has been created.
  Pending,

  /// When admin has not yet approved. Buyer has approved.
  Inprogress,

  /// When seller has not yet uploaded driver details. Admin has approved.
  Processing,

  /// When buyer has not yet received product. Seller has sent driver details.
  Ongoing,

  /// When buyer has recieved product but not shown satisfaction. Buyer has received product.
  Finalizing,

  /// When buyer is satisfied and admin pays the seller the money
  Completed,

  /// Do i need to explain this one? 😂
  Cancelled,
}
