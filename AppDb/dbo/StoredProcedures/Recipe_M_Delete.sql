-- =============================================
-- Author:		Chiraj
-- Create date: 2019-2-11
-- Description:	Delete Recipe and related details
-- =============================================
CREATE PROCEDURE [dbo].[Recipe_M_Delete] 
	@RecipeCode VARCHAR(6),
	@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- BEfore delete recipe check recipe is exist
	DECLARE @Id BIGINT
	SELECT @Id = Id FROM RecipeHeader WHERE RecipeCode=@RecipeCode AND PropertyId=@PropertyId
	-- Audit trail ----------------------------		
	EXEC HotelResWeb_AuditTail_WriteToLog 'RecipeHeader',@Id,'POS','POSRHD','D',0,'','','','','',@PropertyId
	-- End of Audit trail ---------------------

	DELETE FROM RecipeHeader WHERE  RecipeCode=@RecipeCode and PropertyId=@PropertyId
    
END

GO

