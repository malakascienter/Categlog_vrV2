CREATE PROCEDURE dbo.SP_Discount_GetSectionLookup
    @SectionCode VARCHAR(20),
    @PropertyId  INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Sp   NVARCHAR(128);
    DECLARE @Proc NVARCHAR(300);

    SELECT @Sp = DropdownSp
      FROM dbo.INV_DiscountSectionTypes
     WHERE SectionCode = @SectionCode
       AND IsActive = 1;

    -- Allow only lookup SPs that follow the naming rule and really exist
    IF @Sp IS NULL
       OR @Sp NOT LIKE N'SP[_]DiscountLookup[_]%'
       OR OBJECT_ID(N'dbo.' + QUOTENAME(@Sp), N'P') IS NULL
    BEGIN
        RAISERROR('No valid dropdown source is set for section %s.', 16, 1, @SectionCode);
        RETURN;
    END

    SET @Proc = N'dbo.' + QUOTENAME(@Sp);
    EXEC @Proc @PropertyId = @PropertyId;
END

GO

