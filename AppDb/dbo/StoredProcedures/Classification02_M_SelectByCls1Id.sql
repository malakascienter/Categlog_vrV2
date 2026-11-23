
CREATE PROCEDURE Classification02_M_SelectByCls1Id
	@PropertyId INT,
	@Cls01Id INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * FROM POS_Classification02 WITH(NOLOCK) WHERE PropertyId = @PropertyId AND Classification01Id = @Cls01Id

END

GO

