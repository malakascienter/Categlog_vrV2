
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Save_TransactionTypesWiseNextNumber]
	@LocationId INT,
	@CompanyId INT,
	@TransactionTypeId INT,
	@LengthOfFormating  INT 
AS
BEGIN
	
	IF EXISTS(SELECT * FROM TransactionTypeWiseNextNumbers WHERE TransactionType = @TransactionTypeId and PropertyID =@CompanyId and   LocationID =  @LocationID) 
	BEGIN
		 RAISERROR ('Already Exists.', -- Message text.
               16, -- Severity.
               1 -- State.
               );
	RETURN
	END
	
INSERT INTO [dbo].[TransactionTypeWiseNextNumbers]
           ([PropertyID]
           ,[LocationID]
           ,[TransactionType]
           ,[NextNumber]
           ,[LengthOfFormatting])
     VALUES
           (
		    @CompanyId,
		    @LocationID,
			@TransactionTypeId,
			0,
			@LengthOfFormating)

			
 
	
END

GO

