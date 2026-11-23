
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPP_GetALL_WorkDetails] 
	-- Add the parameters for the stored procedure here
	@WorkID int
AS
BEGIN
  
 SELECT        dbo.WorkDetails.RateAnalysisHeaderID, dbo.WorkDetails.WorkID, dbo.WorkDetails.Id, dbo.RateAnalysisHeaders.RateCode, dbo.WorkDetails.Quantity, dbo.WorkDetails.Rate,dbo.RateAnalysisHeaders.Description AS Discription
FROM            dbo.WorkDetails INNER JOIN
                         dbo.RateAnalysisHeaders ON dbo.WorkDetails.RateAnalysisHeaderID = dbo.RateAnalysisHeaders.Id
WHERE        (dbo.WorkDetails.WorkID = @WorkID)

  
END

GO

