
CREATE PROCEDURE [dbo].[Aggregators_M_Select] 
@PropertyId INT
AS
BEGIN
	 
	SET NOCOUNT OFF;

	SELECT * FROM POS_Aggregators WHERE PropertyId = @PropertyId
END

GO

