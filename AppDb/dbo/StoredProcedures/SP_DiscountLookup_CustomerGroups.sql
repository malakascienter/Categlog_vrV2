CREATE PROCEDURE dbo.SP_DiscountLookup_CustomerGroups
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF DB_ID(N'OrderTaking_CMN') IS NOT NULL
        EXEC sp_executesql N'SELECT CAST(cg.Id AS VARCHAR(20)) AS Code, cg.Name AS Name
                               FROM OrderTaking_CMN.dbo.CustomerGroup cg
                              ORDER BY cg.Name;';
    ELSE
        SELECT CAST(NULL AS VARCHAR(20)) AS Code, CAST(NULL AS VARCHAR(100)) AS Name
         WHERE 1 = 0;
END

GO

