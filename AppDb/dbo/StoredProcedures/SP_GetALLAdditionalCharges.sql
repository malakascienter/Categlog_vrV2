-- =============================================
-- Author:		ISURU PRAMODYA
-- Create date: MARCH 02 
-- Description:	<Description,,>

-- [dbo].[SP_GetALLAdditionalCharges] 1
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetALLAdditionalCharges]
(
	@propertyId INT
)
AS
BEGIN
	SET NOCOUNT ON;

	--added by isuru 2023-08-04
	DECLARE @GLCompCode VARCHAR(100)

	SELECT @GLCompCode=Code
	FROM COMPANIES
	WHERE CompanyID = @propertyId
	--end

	SELECT DISTINCT D.Level1 , A.Id,A.Id, A.CompanyID, A.Code, A.Name, A.IsAddToItemCost, A.AccountID, A.IsActive, A.IPAddress, A.CreatedUserID, A.LastModUserID, A.CreatedDate, A.LastModDate
	FROM AdditionalChargesDetails A
	INNER JOIN [dbo].[Destinity_GLIntegrationAccountMapping] D ON D.Level1 = A.Id
	WHERE D.BlockCode='ADD' -- ISN added only for testing do not use in Live servers
	AND A.IsActive=1 AND D.GLCompCode=@GLCompCode

END

GO

