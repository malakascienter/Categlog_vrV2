
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- SPP_GetALLBoqWiseItems 8,5,72,5
-- SPP_GetALLBoqWiseItems 8,0,0,5
-- SPP_GetALLBoqWiseItemsView 2,4,3,2
-- =============================================
CREATE PROCEDURE [dbo].[SPP_GetALLBoqWiseItemsView] 
	-- Add the parameters for the stored procedure here
    @SectionID INT = 0 ,
    @WorkID INT = 0 ,
    @ProjectID INT = 0,
	@BoqID INT = 0
AS
    BEGIN
	
        SELECT DISTINCT
                SH.Name ,
                SH.Id,
				BRAD.IsPercentageOrValue,
				BRAD.DiscountPercentage,
				BRAD.DiscountValue,
				SUM(BRAD.Quantity*MBH.RateQtyInWork)
				 AS Quantity
        FROM    dbo.BOQMainWorkAllocations BMA
		     
                INNER JOIN dbo.BOQSubWorkAllocations BSA ON BMA.Id = BSA.MainWorkID
                INNER JOIN dbo.WorkHeaders WH ON WH.Id = BSA.WorkID
                INNER JOIN dbo.BOQRateanalysisAllocationHeaders MBH ON MBH.BOQID = BSA.BOQID
                                                              AND MBH.WorkID = BSA.Id
                INNER JOIN dbo.BOQRateanalysisAllocationDetails BRAD ON BRAD.RateID = MBH.RateAnalysisID
                                                              AND BRAD.BOQID = MBH.BOQID
                INNER JOIN dbo.StockItemHeaders SH ON SH.Id = BRAD.ItemID
				INNER JOIN dbo.BOQHeaders BH ON BH.Id=BRAD.BOQID AND BH.Finalized=1 AND BH.Approve=1
        WHERE   BRAD.ItemType = 'I' AND BH.ProjectID=@ProjectID
                AND BMA.Id = ( CASE WHEN @SectionID =-999 THEN BMA.Id
                                    ELSE @SectionID
                               END )
                AND BSA.Id = ( CASE WHEN @WorkID = -999 THEN BSA.Id
                                    ELSE @WorkID
                               END )
               

				AND BRAD.BOQID=(CASE WHEN @BoqID=-999 THEN BRAD.BOQID ELSE @BoqID END)
				
				
				
				 GROUP BY 
							   SH.Name ,
                SH.Id,
				BRAD.IsPercentageOrValue,
				BRAD.DiscountPercentage,
				BRAD.DiscountValue

				

    END

GO

