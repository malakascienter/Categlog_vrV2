-- =============================================
-- Author:		chiraj
-- Create date: 2020-06-8
-- Description:	ExecutiveMember_M_Select
-- =============================================
CREATE PROCEDURE [dbo].[ExecutiveMember_M_Select]
	@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   Select * FROM [dbo].[POS_ExecutiveMember] WHERE PropertyId=@PropertyId
END

GO

