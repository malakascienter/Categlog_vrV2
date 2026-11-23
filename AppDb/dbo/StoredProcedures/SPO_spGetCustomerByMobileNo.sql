
-- =============================================
-- Author:		Dilshan
-- Create date: 2025-10-14
-- Description:	SpeacialOrderRevamp
-- =============================================
-- EXEC SPO_spGetCustomerByMobileNo '0702375051'
CREATE     PROCEDURE [dbo].[SPO_spGetCustomerByMobileNo]
	@MobileNo VARCHAR(20)
AS
BEGIN

	SET NOCOUNT ON;

	IF EXISTS (
        SELECT 1 
        FROM SPO_Customer 
        WHERE MobileNumber = @MobileNo 
          AND DocumentStatus = 'P'
    )
    BEGIN
        RAISERROR('Customer approval is pending.', 16, 1);
        RETURN;
    END

	SELECT C.*,CT.CustomerTypeName 
	FROM SPO_Customer C INNER JOIN SPO_CustomerType CT ON C.CustomerTypeID = CT.ID
	WHERE C.MobileNumber = @MobileNo AND C.DocumentStatus = 'C'
END

GO

