CREATE FUNCTION EncodeVoucher(@number INT)
RETURNS NVARCHAR(10)
AS
BEGIN
    DECLARE @Charset NVARCHAR(36) = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    DECLARE @CharsetLength INT = LEN(@Charset)
    DECLARE @encodedChars NVARCHAR(10) = ''
    DECLARE @index INT
    DECLARE @i INT = 0

    WHILE @i < 10
    BEGIN
        SET @index = (@number + @i) % @CharsetLength + 1
        SET @encodedChars = @encodedChars + SUBSTRING(@Charset, @index, 1)
        SET @number = @number / @CharsetLength
        SET @i = @i + 1
    END

    RETURN @encodedChars
END

GO

