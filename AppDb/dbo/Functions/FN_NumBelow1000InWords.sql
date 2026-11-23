
/* ---------------------------------------------------------------------------
   1. Helper: convert 1..999 to words
   --------------------------------------------------------------------------- */
CREATE     FUNCTION [dbo].[FN_NumBelow1000InWords] (@n INT)
RETURNS VARCHAR(200)
AS
BEGIN
    DECLARE @r VARCHAR(200) = '';
    DECLARE @h INT = @n / 100;
    DECLARE @t INT = @n % 100;

    DECLARE @Ones TABLE (n INT, w VARCHAR(20));
    INSERT INTO @Ones (n, w)
    VALUES (1,'One'),(2,'Two'),(3,'Three'),(4,'Four'),(5,'Five'),
           (6,'Six'),(7,'Seven'),(8,'Eight'),(9,'Nine'),(10,'Ten'),
           (11,'Eleven'),(12,'Twelve'),(13,'Thirteen'),(14,'Fourteen'),(15,'Fifteen'),
           (16,'Sixteen'),(17,'Seventeen'),(18,'Eighteen'),(19,'Nineteen');

    DECLARE @Tens TABLE (n INT, w VARCHAR(20));
    INSERT INTO @Tens (n, w)
    VALUES (2,'Twenty'),(3,'Thirty'),(4,'Forty'),(5,'Fifty'),
           (6,'Sixty'),(7,'Seventy'),(8,'Eighty'),(9,'Ninety');

    IF @h > 0
        SET @r = (SELECT w FROM @Ones WHERE n = @h) + ' Hundred';

    IF @t > 0
    BEGIN
        IF @h > 0
            SET @r = @r + ' And ';

        IF @t < 20
            SET @r = @r + (SELECT w FROM @Ones WHERE n = @t);
        ELSE
        BEGIN
            SET @r = @r + (SELECT w FROM @Tens WHERE n = @t / 10);
            IF @t % 10 > 0
                SET @r = @r + ' ' + (SELECT w FROM @Ones WHERE n = @t % 10);
        END
    END

    RETURN @r;
END

GO

