
CREATE PROCEDURE [dbo].[MW_spGetTableDetailsById]
	@PropertyId INT,
	@TableId VARCHAR(50)
AS
BEGIN

	SELECT TableID AS TableId,TableName  AS TableName  FROM POS_TableList WHERE TableID = CONVERT(INT,@TableId) AND PropertyId = @PropertyId
END

GO

