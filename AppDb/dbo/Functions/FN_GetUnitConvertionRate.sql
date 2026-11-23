
CREATE FUNCTION [dbo].[FN_GetUnitConvertionRate]
(
    @PropertyId INT,
    @FromUnitId INT,
    @ToUnitId INT
)
RETURNS DECIMAL(38,20)
AS
BEGIN
    DECLARE @Rate DECIMAL(38,20)

    IF @FromUnitId = @ToUnitId
        RETURN CAST(1.0 AS DECIMAL(38,20))

    SELECT TOP 1 @Rate = Value
    FROM UnitConversions
    WHERE FromUnitId = @FromUnitId AND ToUnitId = @ToUnitId AND CompanyId = @PropertyId

    IF @Rate IS NOT NULL
        RETURN @Rate

    DECLARE @ReverseValue FLOAT

    SELECT TOP 1 @ReverseValue = CAST(Value AS FLOAT)
    FROM UnitConversions
    WHERE FromUnitId = @ToUnitId AND ToUnitId = @FromUnitId AND CompanyId = @PropertyId

    IF @ReverseValue IS NOT NULL AND @ReverseValue <> 0
    BEGIN
        SET @Rate = CAST(CAST(1.0 AS FLOAT) / @ReverseValue AS DECIMAL(38,20))
        RETURN @Rate
    END

    RETURN CAST(-1.0 AS DECIMAL(38,20))
END

GO

