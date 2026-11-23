
/* ---------------------------------------------------------------------------
   2. Amount to words - gazette clause 4.1.g.iv "total consideration in words"
      e.g. 19352.00 -> 'Nineteen Thousand Three Hundred And Fifty Two Only'
   --------------------------------------------------------------------------- */
CREATE     FUNCTION [dbo].[FN_AmountInWords] (@Amount DECIMAL(18,2))
RETURNS VARCHAR(1000)
AS
BEGIN
    IF @Amount IS NULL
        RETURN '';

    DECLARE @Num   BIGINT = FLOOR(ABS(@Amount));
    DECLARE @Cents INT    = CAST(ROUND((ABS(@Amount) - FLOOR(ABS(@Amount))) * 100, 0) AS INT);
    DECLARE @r     VARCHAR(1000) = '';
    DECLARE @Ord   INT = 1;
    DECLARE @Div   BIGINT;
    DECLARE @Nm    VARCHAR(20);
    DECLARE @Part  INT;

    DECLARE @Scales TABLE (Ord INT, Div BIGINT, Nm VARCHAR(20));
    INSERT INTO @Scales (Ord, Div, Nm)
    VALUES (1, 1000000000, 'Billion'),
           (2, 1000000,    'Million'),
           (3, 1000,       'Thousand'),
           (4, 1,          '');

    IF @Num = 0
        SET @r = 'Zero';
    ELSE
    BEGIN
        WHILE @Ord <= 4
        BEGIN
            SELECT @Div = Div, @Nm = Nm FROM @Scales WHERE Ord = @Ord;

            SET @Part = CAST((@Num / @Div) % 1000 AS INT);

            IF @Part > 0
                SET @r = LTRIM(@r + ' ' + dbo.FN_NumBelow1000InWords(@Part)
                             + CASE WHEN @Nm <> '' THEN ' ' + @Nm ELSE '' END);

            SET @Ord = @Ord + 1;
        END
    END

    -- The gazette requires values without cents, so this normally never fires.
    IF @Cents > 0
        SET @r = @r + ' And Cents ' + dbo.FN_NumBelow1000InWords(@Cents);

    RETURN LTRIM(RTRIM(@r)) + ' Only';
END

GO

