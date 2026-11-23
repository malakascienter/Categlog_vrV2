CREATE FUNCTION DecodeVoucher(@encodedString NVARCHAR(10))
RETURNS INT
AS
BEGIN
    DECLARE @Charset NVARCHAR(36) = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    DECLARE @CharsetLength INT = LEN(@Charset)
    DECLARE @decodedNumber INT = 0
    DECLARE @i INT = LEN(@encodedString)

    WHILE @i > 0
    BEGIN
        DECLARE @currentChar NVARCHAR(1) = SUBSTRING(@encodedString, @i, 1)
        DECLARE @charIndex INT = CHARINDEX(@currentChar, @Charset) - 1
        SET @decodedNumber = @decodedNumber * @CharsetLength + @charIndex - (@i - 1)
        SET @i = @i - 1
    END

    RETURN @decodedNumber
END

GO

