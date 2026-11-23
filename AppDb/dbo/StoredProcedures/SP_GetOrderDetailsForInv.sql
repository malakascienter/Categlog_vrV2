-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[dbo].[SP_GetOrderDetailsForInv] 1011
CREATE PROCEDURE [dbo].[SP_GetOrderDetailsForInv] 
@OrderHeaderID INT
AS
    BEGIN
        SELECT  SP.Id AS SalesPersonID ,
                SP.SalesPersonName AS SalesName ,
                C.Id AS CustormerID,
                C.CustomerName ,
                C.VatNumber ,
                OH.Id AS OrderHeaderID,
				C.AddLine1+','+C.AddLine2+','+C.AddLine3 AS 'CustormerAddress'
        FROM    dbo.OrderHeaders OH
                LEFT JOIN dbo.Customers C ON C.Id = OH.CustomerID
                LEFT JOIN dbo.SalesPersons SP ON SP.Id = OH.SalesPersonID
        WHERE   OH.Id = @OrderHeaderID
    END

GO

