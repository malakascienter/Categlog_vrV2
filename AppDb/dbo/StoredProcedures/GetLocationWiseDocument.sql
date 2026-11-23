-- =============================================
-- Last Modified by		: Nivesh
-- Last Modified date	: 2025-11-10
-- Description:	Get Location-wise documents
-- =============================================
-- GetstockCategorywiseitems 3
CREATE PROCEDURE [dbo].[GetLocationWiseDocument]
	@LocationId INT
AS
BEGIN
	
	SELECT 
		DocumentNo,
		Id 
	FROM RequestHeaders 
	WHERE LocationID =  
	CASE 
	WHEN @LocationId = -999 
	THEN LocationID 
	ELSE  @LocationId 
	END 
	AND DocumentStatus = 'P' 
	AND RequestType = 'RP' 
	AND IsApproved = 1
	AND QuotationStatus IN ('P', 'X') --Added by Nivesh 2025-11-10 - For filtering qutation related PR
	-- IN ('P', 'X') add by ravindu 2025-12-01 For Quatation Rejected Modification.

END

GO

