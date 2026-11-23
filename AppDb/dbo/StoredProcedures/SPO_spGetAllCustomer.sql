
-- =============================================
-- Author:		Dilshan
-- Create date: 2025-10-14
-- Description:	SpeacialOrderRevamp
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_spGetAllCustomer]
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT C.*,CT.CustomerTypeName
	FROM SPO_Customer C INNER JOIN SPO_CustomerType CT ON C.CustomerTypeID = CT.ID
	WHERE C.DocumentStatus = 'C' AND C.PropertyId = @PropertyId

    
END

GO

