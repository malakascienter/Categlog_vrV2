CREATE PROCEDURE dbo.sp_GetUniquePrefix
@PropertyId INT
AS
BEGIN
    DECLARE @Prefix VARCHAR(2)
    
    -- Loop to generate and check if the prefix is unique
    WHILE 1 = 1
    BEGIN
        -- Generate a random two-character prefix using NEWID
        SET @Prefix = LEFT(CONVERT(VARCHAR(36), NEWID()), 2)
        
        -- Check if the generated prefix already exists in the table
        IF NOT EXISTS (
            SELECT 1 
            FROM [Categlog_vrV2].[dbo].[Category] 
            WHERE [Prefix] = @Prefix AND PropertyId = @PropertyId
        )
        BEGIN
            -- If it doesn't exist, return the prefix
            SELECT @Prefix AS UniquePrefix
            RETURN
        END
    END
END

GO

