-- =============================================
-- Author:		Chiraj	
-- Create date: 2018-8-29
-- Description:	PaymentType_M_Select_for_sync_Oulets
-- =============================================
CREATE PROCEDURE [dbo].[PaymentType_M_Select_for_sync_Oulets]
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT * FROM PaymentTypes
  
END

GO

