-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- SP_GetAllBillsDetails 1
CREATE PROCEDURE [dbo].[SP_GetAllBillsDetails]
@BillID INT 
AS
BEGIN
					
SELECT  0 AS ProjectID,BD.Id AS Id, BD.BOQID,''AS BOQCode,WorkDoneID AS WorkDoneID,BD.amount,BD.MainWorkID AS MainworkId,MWA.Description AS MainWorkName,BD.WokeID AS WorkId,WH.Description AS WorkName,WDR.Value  AS AccessValue,WDR.BilledValue AS BAmount,TG.Name AS TaxName,TG.TaxGroupId
FROM dbo.BillDetails  BD 
INNER JOIN dbo.BOQMainWorkAllocations MWA ON MWA.Id = BD.MainWorkID
INNER JOIN dbo.WorkHeaders WH ON WH.Id = BD.WokeID
INNER JOIN dbo.WorkDoneRegistries WDR ON WDR.Id = BD.WorkDoneID
INNER JOIN dbo.TaxGroups TG ON TG.TaxGroupId=BD.taxGroupId
WHERE BD.BillID=@BillID AND WDR.Value>WDR.BilledValue
END

GO

