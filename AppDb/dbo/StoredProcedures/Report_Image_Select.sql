
-- =============================================
-- Author:		chiraj
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Report_Image_Select] 
	@PropertyId INT
AS
BEGIN
	--SELECT  Id, CompanyLogo, Footer, Copyright, CompanyName, CompnyAddress, ContactNo, ContactEmail
	--FROM  ReportProperties
	SELECT * FROM ReportProperties WHERE PropertyId=@PropertyId
END

GO

