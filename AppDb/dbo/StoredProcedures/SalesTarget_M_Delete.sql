-- =============================================
-- Author:		Chiraj
-- Create date: 2020-05-16
-- Description:	Save Item Breakown
-- =============================================
CREATE PROCEDURE [dbo].[SalesTarget_M_Delete]
	@Id INT,
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;

	DELETE FROM POS_SalesTarget 
	WHERE PropertyId = @PropertyId AND Id = @Id

END

GO

