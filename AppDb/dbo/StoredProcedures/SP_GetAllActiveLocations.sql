-- =============================================
-- Author:		<Nivesh>
-- Create date: <2023-12-07>
-- Description:	<Get all active location>
-- =============================================
--SP_GetAllActiveLocations 1

CREATE PROCEDURE [dbo].[SP_GetAllActiveLocations]
@CompanyID INT
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT Code,
	Name,
	CompanyID,
	CreatedDate,
	CreatedUserID,
	IPAddress,
	DefaultLocation,
	IsMainStore,
	Id,
	IsActive,
	LastModDate,
	LastModUserID,
	LocationType,
	Prefix
	FROM locations  
	WHERE CompanyID = @CompanyID 
	AND IsActive = 1
END

GO

