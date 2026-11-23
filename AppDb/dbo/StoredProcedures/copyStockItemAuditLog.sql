-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE copyStockItemAuditLog
	@tempTable VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @tempStItDe int, @UserId int, @CompanyId int

	CREATE TABLE #ParsedTable(
	Id INT ,
		UserId INT ,
		CompanyId INT 
	)
	INSERT INTO #ParsedTable
	SELECT *
	  -- temporary table to store the parsed results
	FROM OPENJSON(@tempTable)
	WITH (
		Id INT '$.Id',
		UserId INT '$.UserId',
		CompanyId INT '$.CompanyId'
	);

		WHILE EXISTS (SELECT 1 FROM #ParsedTable)
		BEGIN
			SELECT TOP(1) @tempStItDe = Id,@UserId =UserId, @CompanyId = CompanyId FROM #ParsedTable
			EXEC Inventry_AuditTail_WriteToLog 'stockitemdetails', @tempStItDe, 'INV', 'SIDI', 'I', @UserId,@CompanyId, '', ''
			DELETE TOP(1) FROM #ParsedTable
		END
END

GO

