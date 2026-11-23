
CREATE PROCEDURE Classification01_M_Select
	@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * FROM POS_Classification01 WITH(NOLOCK) WHERE PropertyId = @PropertyId

END

GO

