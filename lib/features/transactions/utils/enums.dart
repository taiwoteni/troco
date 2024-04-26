// ignore_for_file: constant_identifier_names

enum Category { Business, Merchant, Admin }

enum TransactionPurpose { Buying, Selling }

enum TransactionCategory{ Product, Service, Virtual}

enum ProductCondition {New,ForeignUsed,NigerianUsed}

enum InspectionPeriod {Hour, Day}

enum TransactionStatus {
  Pending, /// When buyer has not yet approved. Transaction has been created.

  Inprogress, /// When admin has not yet approved. Buyer has approved.

  Processing, /// When seller has not yet uploaded driver details. Admin has approved.

  Ongoing, /// When buyer has not yet received product. Seller has sent driver details.

  Finalizing, /// When buyer has recieved product but not shown satisfaction. Buyer has received product.
  
  Completed,  /// When seller is satisfied and admin pays the seller the money
  
  Cancelled, /// Do i need to explain this one? 😂
}
