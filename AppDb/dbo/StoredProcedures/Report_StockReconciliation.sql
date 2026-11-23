-- =============================================  
-- Author:  Yasiru  
-- Create date: 2017-09-07  
-- Description: User Roles  
-- =============================================  
--[dbo].[Report_StockReconciliation]'SRN0000009','HOF'
CREATE PROCEDURE [dbo].[Report_StockReconciliation]
@DocNo Nvarchar(50),
@LocationCode nvarchar(20)
--,@HeaderId int  
AS  
BEGIN  
SET NOCOUNT ON; 

Select DSD.ItemCode,DSH.DocNo,SM.Description AS ItemName,DSD.Qty,DSD.Unit,DSH.Remark,LR.description AS Location
from  DailyStockReconciliationDetails AS DSD
Inner join DailyStockReconciliationHeaders AS DSH ON DSD.DailyStockReconciliationHeaderId = DSH.Id
Inner join Location_Ref AS LR ON LR.code = DSH.LocationCode
INNER join StockMaster AS SM ON SM.ItemNo = DSD.ItemCode
Where DSH.DocNo = @DocNo 
AND  DSH.LocationCode = @LocationCode
--AND DSH.Id =@HeaderId
Group By DSD.ItemCode,DSD.Qty,DSD.Unit,DSH.DocNo,DSH.Remark,LR.description,SM.Description
END

GO

