/*  The field list the builder renders and the compiler resolves against. Sending
    SqlExpression to the client is harmless -- it is already administrator-
    controlled and the compiler never accepts one from a request -- but it is
    excluded anyway, because the browser has no use for it.                      */
CREATE PROCEDURE dbo.LTYC_SegmentAttribute_SelectAll
    @IncludeSql bit = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT a.AttributeCode,
           a.DisplayName,
           a.Category,
           a.DataType,
           a.AllowedOperators,
           CASE WHEN @IncludeSql = 1 THEN a.SqlExpression ELSE '' END AS SqlExpression,
           a.SourceAlias,
           a.IsBrazeSyncable,
           a.IsPersonalisable,
           a.SortOrder,
           a.IsActive
    FROM   dbo.LTYC_SegmentAttribute AS a
    WHERE  a.IsActive = 1
    ORDER BY a.SortOrder, a.DisplayName;
END

GO

