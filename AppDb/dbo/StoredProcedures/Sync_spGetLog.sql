

CREATE PROCEDURE [dbo].[Sync_spGetLog]

AS
DECLARE @IsWithErrors BIT, @MaxDate VARCHAR(100)
SET @IsWithErrors = 0

IF EXISTS(SELECT IsError FROM Sync_Log WHERE IsError = 1)
	BEGIN
		SET @IsWithErrors = 1
	END

	SET @MaxDate = (SELECT CAST(ISNULL(MAX(SysDate),'') AS VARCHAR(100)) FROM Sync_Log)

SELECT	ID, Description, SysDate, IsError, @IsWithErrors AS IsWithErrors, @MaxDate AS MaxDate
FROM	Sync_Log
ORDER BY SysDate

GO

