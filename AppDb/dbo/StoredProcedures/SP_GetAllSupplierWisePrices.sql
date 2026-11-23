-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetAllSupplierWisePrices]
	@ProjectID INT,
	@SupplierID INT 
AS
BEGIN
	SELECT P.Id,P.ProjectID ,
          P.SupplierID ,
          P.StockItemID ,
          P.Price ,
          P.DiscountValue ,
          P.NetPrice ,
          P.IPAddress ,
          P.CreatedUserID ,
          P.LastModUserID ,
          P.CreatedDate ,
          P.LastModDate,PD.ProjectName AS ProjectName,S.Name AS SupplierName,SH.name AS StockItemName,SH.StockItemCode AS Code FROM ProjectWiseSupplierPrices P INNER JOIN dbo.ProjectDetails PD ON PD.Id=P.projectid INNER JOIN dbo.Suppliers S ON S.ID=P.supplierid 
	INNER JOIN dbo.StockItemHeaders SH ON SH.id=P.StockItemID WHERE P.projectid=@ProjectID AND P.supplierid=@SupplierID
END

GO

