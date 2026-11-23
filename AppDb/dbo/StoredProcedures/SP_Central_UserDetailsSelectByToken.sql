-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2023 JULY 14
-- Description:	Checking User Validation with token
-- [dbo].[SP_Central_UserDetailsSelectByToken] 'c4c37a92-09ec-4418-8266-79fe1bbd2346'
-- =============================================
CREATE PROCEDURE [dbo].[SP_Central_UserDetailsSelectByToken]
	@token NVARCHAR(MAX)
AS
BEGIN

	SET NOCOUNT ON;

   EXEC  [dbo].[Central_UserDetailsSelectByToken] @token
END

GO

