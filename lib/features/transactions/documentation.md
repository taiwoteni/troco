This is the documentation for Transactions -- i.e the 'Transaction feature'.

Following the CLEAN architectural pattern, this feature is split into 4 layers:
- data layer
- domain layer
- presentation layer
- utils layer

The Data Layer is split into two separate sub-layers:
- datasource : which serves as the layer where preset data are declared and stored
- models : serves as the layer where non-business related entities are stored. Entities such as:
  - driver-details-holder
  - process-model (Model designed to simplify Timeline processes of transactions)
  - create-transaction-data-holder (A data storing class which uses stores details of transactions to be created using static variables and methods)