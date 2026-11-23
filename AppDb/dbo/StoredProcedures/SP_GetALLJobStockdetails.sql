-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--SP_GetALLJobStockdetails 11,2,1
CREATE PROCEDURE [dbo].[SP_GetALLJobStockdetails]
    @JobheaderID INT ,
    @Mode INT,
	@Location INT 
AS
    BEGIN

        IF ( @Mode = 1 )
            BEGIN
                SELECT  
				      JD.Id,JD.JobHeaderID,JD.OutPutStockItemHeaderID,JD.StockItemHeaderID,JD.Qty,JD.UnitID,JD.RequestQty,JD.IssueQty,
	
                        SH.Name,SD.Name AS OutPutHeaderName
                FROM    dbo.JobInputDetails JD
                        INNER JOIN dbo.StockItemHeaders SH ON SH.Id = JD.StockItemHeaderID	
						INNER JOIN dbo.StockItemHeaders SD ON SD.Id=JD.OutPutStockItemHeaderID				
                WHERE   JobHeaderID = @JobheaderID ORDER BY OutPutHeaderName ASC

            END 

		ELSE IF(@Mode=2)
		BEGIN
		    SELECT   JD.Id,JD.JobHeaderID,JD.OutPutStockItemHeaderID,JD.StockItemHeaderID,JD.Qty,JD.UnitID,JD.RequestQty,JD.IssueQty,
                        SH.Name,STD.QuantityInHand,SD.Name AS OutPutHeaderName
                FROM    dbo.JobInputDetails JD
                        INNER JOIN dbo.StockItemHeaders SH ON SH.Id = JD.StockItemHeaderID
						INNER JOIN dbo.StockItemHeaders SD ON SD.Id=JD.OutPutStockItemHeaderID	
						INNER JOIN dbo.StockItemDetails STD ON STD.StockItemHeaderID=SH.Id							
                WHERE   JobHeaderID = @JobheaderID AND STD.LocationID=@Location ORDER BY OutPutHeaderName ASC
		END
        

----		SET @printPaySlip = (
----(select  CAST( '<EmployeeID>'+CAST(EmployeeID as NVARCHAR(40))+ '</EmployeeID>' as XML) from EmployeeDetails EmployeeList
----where EmployeeID between @FromEmployeeID and @ToEmployeeID and companyID = @CompanyID 
----FOR XML AUTO, type,root('Data')
 
--) )
    END

GO

