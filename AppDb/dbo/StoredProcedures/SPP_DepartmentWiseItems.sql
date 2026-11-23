-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
--SPP_DepartmentWiseItems 1,1,1,1
-- =============================================
CREATE PROCEDURE [dbo].[SPP_DepartmentWiseItems] 

@DepartmentID INT, @BOQID INT, @LocationID INT, @ProjectID INT AS BEGIN DECLARE @temp AS TABLE (id INT, name VARCHAR(MAX),
                                                                                                             quantity INT, IsExist BIT DEFAULT 0,
                                                                                                                                               balance INT,Unit int)
		INSERT INTO @temp (ID, name, quantity, balance, Unit)
		SELECT DISTINCT a.id,
						a.name AS Name,
						c.BOQQuantity,
						sum(c.BalanceQuantity-c.SuspendedQuantity) as BalanceQuantity,
						c.UnitID
		FROM StockItemHeaders a
		INNER JOIN MRNItemRegistries c ON c.ItemId = a.id
		INNER JOIN dbo.BOQHeaders B ON c.BOQId=B.Id
		WHERE c.BOQId=@BOQID
		  AND c.DepId=@DepartmentID
		  AND c.ProjectID=@ProjectID
		  AND c.BalanceQuantity>0
		  AND B.Approve=1
		  AND B.BOQStatus=1
		  --AND a.Isbundle=0
		GROUP BY a.id,
				 a.name,
				 c.UnitID,
				 c.BOQQuantity
				 --SELECT * FROM @temp
				
		UPDATE I
		SET I.IsExist = 1
		FROM @temp I
		INNER JOIN StockItemHeaders b ON I.id = b.id 
		INNER JOIN StockItemDetails c ON c.StockItemHeaderID = b.id
		WHERE c.LocationID = @LocationID
		  SELECT id AS ItemID,
				 Unit,
				 @BOQID AS BOQID,
				 name AS Name,
				 @DepartmentID AS DepartmentID,
				 '' AS UnitName,
				 balance AS Quantity,
				 @LocationID AS LOCATION,
				 0 AS UnitPrice,
				 IsExist
		  FROM @temp



END

GO

