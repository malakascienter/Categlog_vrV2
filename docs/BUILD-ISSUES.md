# Build issues in the imported database

The project builds with **0 errors**, but 7 legacy objects had real errors and are **quarantined**:
they stay in Git, but are not compiled and therefore **not deployed**. Fix each one, then delete its
`<Build Remove>` / `<None Include>` lines in `AppDb/AppDb.sqlproj`.

| Object | Problem |
|---|---|
| `dbo.fn_GetLastCompletedApproval` | Uses synonym `dbo.CentralUsers` (points to another database); ambiguous `UserName` / `Id` |
| `dbo.Api_Insert_OrderItem_UberEat` | Column `POS_OutsideOrders.UberEatOrderId` does not exist |
| `dbo.DayEnd_ConsigmentSuppliersSales` | Columns `StockTransactionDetails.SaleQty`, `ConsigmentItemsSalesDetails.StockItemID` do not exist; ambiguous `SaleQty` |
| `dbo.Getthesearrivals` | Columns `ReservationStatus.IsActive`, `IsApplicableToOccupancy` do not exist |
| `dbo.SPO_GetPaymentDetails` | Ambiguous `ID` (Location_Ref / PaymentTypes / SPO_OrderWisePayment) |
| `dbo.SP_SelectBudgetReEmbrace` | Ambiguous `ID` (BudgetAllocation / Locations / StockTransactionHeaders / Suppliers) |
| `dbo.SupplierExpense_M_Select` | Ambiguous `Id` (SupplierExpense / Suppliers) |

These procedures would also fail at run time on the source database, because SQL Server only checks
column names when a procedure runs.

**Risk:** Dev and Test publish profiles drop objects that are not in the project, so these 7 would be
dropped there. Prod never drops. Fix them before publishing to Dev or Test.

## Settings that make the build pass

In `AppDb.sqlproj`:
- `Microsoft.SqlServer.Dacpacs.Master` is referenced so system procedures resolve
  (`sp_executesql`, `sp_xml_preparedocument`, `INFORMATION_SCHEMA`, ...).
- `TreatTSqlWarningsAsErrors` is **False** and warnings `71502` and `71562` are hidden. They report
  references to other databases (`eFinancials_Accounting`, `Categlog_vrV2`, `CentralAccessDB`,
  `HotelResWeb_AuditTail`, `msdb`) that are not part of this project. Cross-database references
  cannot be checked until those databases have their own projects (add `DatabaseReference` items).
- `RunSqlCodeAnalysis` is **False** to keep the build fast (1.5 minutes for ~1,000 objects).

## Not verified
Publishing this project to a database has not been tested since the import.
