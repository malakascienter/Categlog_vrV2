
-- =============================================
-- Author:		Chamathka Sooriyapala
-- Create date: 2020-06-18
-- Description:	Insert Report Property Image
-- =============================================
CREATE PROCEDURE [dbo].[Insert_ReportProperties_PropertyImage] 
AS
BEGIN
	UPDATE ReportProperties
	--SET CompanyLogo =	(
	--						SELECT * 
	--						FROM OPENROWSET(Bulk 'F:\a\ClubHotelDolpin.png', SINGLE_BLOB) AS img
	--					) WHERE PropertyId=1
	--					UPDATE ReportProperties
	SET CompanyLogo =	(
							SELECT * 
							FROM OPENROWSET(Bulk 'C:\logos\jetwing.png', SINGLE_BLOB) AS img
						) WHERE PropertyId=2
						UPDATE ReportProperties
	
	SET CompanyLogo =	(
							SELECT * 
							FROM OPENROWSET(Bulk 'F:\a\HotelSigiriya.png', SINGLE_BLOB) AS img
						) WHERE PropertyId=3

	
END

GO

