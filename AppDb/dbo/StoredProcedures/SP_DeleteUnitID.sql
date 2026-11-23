-- =============================================
-- Author:		ISURU PRAMODYA
-- Create date: 06 APRIL 2023
-- Description:	CHECKING DELETING UNIT HAD TRANSACTION OR NOT

-- [dbo].[SP_DeleteUnitID] 1298, 4168

-- =============================================
CREATE PROCEDURE [dbo].[SP_DeleteUnitID]
(
	@Id int,
	@UserId int
)
AS
BEGIN
DECLARE @UnitName varchar(50)

	SET NOCOUNT ON;

	--SELECT top(10)*
	--FROM StockTransactionDetails
	--WHERE MasterUnitID = @Id

	--SELECT top(10)*
	--FROM StockItemDetails
	--WHERE MasterUnitID = @Id

	--select top(10)*
	--FROM SupplierWiseItemDetails
	--WHERE PurchaseUnitID = @Id



	--ADDED BY ISURU 2023-06-29 TO PREVENT Deleting units which are already linked to stock items
	IF EXISTS(SELECT 1 FROM StockItemDetails st  where st.MasterUnitID=@Id)
	BEGIN
	SELECT DISTINCT U.Id,U.Name,U.Code,'Found' as TrasactionFound
	FROM Units U
	WHERE U.Id=@Id
	END
	ELSE
	--End
	IF EXISTS(SELECT 1 FROM StockTransactionDetails st INNER JOIN StockItemDetails std on std.MasterUnitID = st.MasterUnitID
			  LEFT JOIN SupplierWiseItemDetails su on su.PurchaseUnitID= st.MasterUnitID where st.MasterUnitID=@Id)
	BEGIN
	SELECT DISTINCT U.Id,U.Name,U.Code,'Found' as TrasactionFound
	FROM Units U
	INNER  JOIN StockTransactionDetails st on u.Id = st.MasterUnitID
	INNER JOIN StockItemDetails std on std.MasterUnitID = st.MasterUnitID
	LEFT JOIN SupplierWiseItemDetails su on su.PurchaseUnitID= st.MasterUnitID
	WHERE U.Id=@Id
	END
	ELSE
	BEGIN
	SELECT @UnitName = Name
	FROM Units
	where Id=@Id

	SELECT 'NotFound' as TrasactionFound
	


	DELETE FROM Units WHERE Id= @Id

	EXEC [dbo].[InsertMasterFileChangeLog] 'Units',4168,'D',@UnitName
	END

END

GO

