-- SPP_GetBoqWiseDiscounts 3,5,8,5
-- SPP_GetBoqWiseDiscounts 3,5,0,0
-- SPP_GetBoqWiseDiscounts 3,5,8,0
CREATE PROCEDURE [dbo].[SPP_GetBoqWiseDiscounts]
    @ProjectID INT ,
    @BoqID INT ,
    @SectionID INT ,
    @WorkID INT
AS
    BEGIN
        SELECT  BWD.ProjectID ,
                P.ProjectName ,
                BWD.BOQID ,
                B.BOQName ,
                BWD.SectionID ,
            CASE WHEN  MWA.[Description] IS NULL THEN 'N/A' ELSE  MWA.[Description] END AS [Description],
                BWD.WorkID ,
            CASE WHEN WH.[Description] IS NULL THEN 'N/A' ELSE WH.[Description] END  AS WorkDescription,
                BWD.BoqDiscount ,
                BWD.SectionDiscount ,
                BWD.WorkDiscount ,
				BWD.RateDiscount,
                BWD.DiscountPercentage ,
                BWD.DiscountValue ,
                BWD.IsPercentageForDiscount,
				BWD.RateID AS RateID,
				CASE WHEN BRAH.[Description] IS NULL THEN 'N/A' ELSE BRAH.[Description] END  AS RateName
               FROM    dbo.BoqWiseDiscounts BWD
                INNER JOIN dbo.ProjectDetails P ON P.Id = BWD.ProjectID
                LEFT JOIN dbo.BOQHeaders B ON B.Id = BWD.BOQID
                LEFT JOIN dbo.BOQMainWorkAllocations MWA ON MWA.Id = BWD.SectionID
                LEFT JOIN dbo.WorkHeaders WH ON WH.Id = BWD.WorkID
				LEFT JOIN dbo.BOQRateanalysisAllocationHeaders BRAH ON BRAH.BOQID = BWD.BoqID AND BRAH.WorkID=BWD.WorkID AND BRAH.ID=BWD.RateID
        WHERE   BWD.ProjectID=@ProjectID AND
		        BWD.BOQID =  @BoqID 
				--Commented	
				--AND BWD.SectionID=@SectionID
				--AND BWD.WorkID=@WorkID	 
                --AND BWD.SectionID = CASE WHEN @SectionID = 0 THEN BWD.SectionID ELSE @SectionID END
                --AND BWD.WorkID = CASE WHEN @WorkID = 0 THEN BWD.WorkID ELSE @WorkID END 
                 



    
END

GO

