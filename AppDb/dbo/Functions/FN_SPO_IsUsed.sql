-- =============================================
-- Author:		Ravindu
-- Create date: 2026-02-25
-- Description:	Check the used
-- =============================================
CREATE   FUNCTION [dbo].[FN_SPO_IsUsed]
(
    @Type VARCHAR(3),  
    @Id   INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @IsUsed BIT = 0;

    IF (@Type = 'CUS')  -- Customer
    BEGIN
        IF EXISTS (SELECT 1 FROM SPO_OrderHeader WHERE CustomerId = @Id)
            SET @IsUsed = 1;
    END

    IF (@Type = 'OT')   -- Order Type
    BEGIN
        IF EXISTS (SELECT 1 FROM SPO_OrderHeader WHERE OrderTypeId = @Id)
            SET @IsUsed = 1;
    END

    IF (@Type = 'CT')   -- Customer Type
    BEGIN
        IF EXISTS (
            SELECT 1 FROM SPO_OrderHeader oh
            INNER JOIN SPO_Customer c ON c.ID = oh.CustomerId
            WHERE c.CustomerTypeID = @Id
        )
        OR EXISTS (
            SELECT 1 FROM SPO_Customer c
            WHERE c.CustomerTypeID = @Id
        )
            SET @IsUsed = 1;
    END

    RETURN @IsUsed;
END

GO

