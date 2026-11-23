
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- SPP_GetALLBoqWiseItemsPriceChange 14,0,0,11
-- SPP_GetALLBoqWiseItemsPriceChange 8,0,0,5
-- SPP_GetALLBoqWiseItemsPriceChange 8,5,0,5
-- =============================================
CREATE PROCEDURE [dbo].[SPP_GetALLBoqWiseItemsPriceChange] 
	-- Add the parameters for the stored procedure here
    @SectionID INT = 0 ,
    @WorkID INT = 0 ,
    @RateID INT = 0,
	@BoqID INT = 0
AS
    BEGIN
	
        SELECT DISTINCT
                SH.Name ,
                SH.Id,
				0,
				0,
				0,
				SUM(CASE WHEN @RateID!=0
				THEN (BRAD.Quantity)
				ELSE 
				(BRAD.Quantity*MBH.RateQtyInWork)
				END) AS Quantity,
				BRAD.UnitPrice AS OldPrice,
				BRAD.UnitPrice AS NewPrice,
				BRAD.BoqID as BoqID,
				BRAD.RateID as RateID
        FROM    dbo.BOQMainWorkAllocations BMA
                INNER JOIN dbo.BOQSubWorkAllocations BSA ON BMA.Id = BSA.MainWorkID
                INNER JOIN dbo.WorkHeaders WH ON WH.Id = BSA.WorkID
                INNER JOIN dbo.BOQRateanalysisAllocationHeaders MBH ON MBH.BOQID = BSA.BOQID
                                                              AND MBH.WorkID = BSA.Id
                INNER JOIN dbo.BOQRateanalysisAllocationDetails BRAD ON BRAD.RateID = MBH.RateAnalysisID
                                                              AND BRAD.BOQID = MBH.BOQID
                INNER JOIN dbo.StockItemHeaders SH ON SH.Id = BRAD.ItemID
        WHERE   BRAD.ItemType = 'I'
                AND BMA.Id = ( CASE WHEN @SectionID = 0 THEN BMA.Id
                                    ELSE @SectionID
                               END )
                AND BSA.Id = ( CASE WHEN @WorkID = 0 THEN BSA.Id
                                    ELSE @WorkID
                               END )
                AND MBH.ID = ( CASE WHEN @RateID = 0 THEN MBH.ID
                                    ELSE @RateID
                               END )
				AND BRAD.BOQID=@BoqID GROUP BY 
							   SH.Name ,BRAD.BoqID,BRAD.RateID,
                SH.Id,
				
				BRAD.UnitPrice ORDER BY SH.Name ASC 

    END

GO

