
CREATE PROCEDURE [dbo].[SP_FilterSearch_UnitConversions]
@from INT,
@to INT,
@search VARCHAR(20), 
@sortType INT,
@sortColumn INT,
@totalRecordCount INT OUTPUT,
@status INT OUTPUT,
@message VARCHAR(20) OUTPUT,
@filterId INT
AS
DECLARE @statusIN INT
SET @statusIN = 0;
SET @message = ''

BEGIN
BEGIN TRY
BEGIN TRANSACTION

SET @search = LTRIM(RTRIM(@search))
set @sortColumn=0

IF (@sortColumn = 0 AND @sortType = 0)
BEGIN
    IF (@search IS NULL OR @search = '')
    BEGIN
        SELECT @totalRecordCount = COUNT(*) FROM UnitConversions WHERE CompanyId = @filterId

        SELECT *
        FROM (
                SELECT *,
                    (ROW_NUMBER() OVER(ORDER BY CreatedDate DESC, ID DESC)) AS RowNum
                FROM dbo.UnitConversions
                WHERE ((FromUnitName LIKE '%' + @search + '%' OR ToUnitName LIKE '%' + @search + '%' OR Value LIKE '%' + @search + '%') AND (CompanyId = @filterId))
            ) AS InvDets
        WHERE RowNum BETWEEN @from AND @to
        ORDER BY CreatedDate DESC, Id DESC
    END
    ELSE
    BEGIN
        SELECT @totalRecordCount = COUNT(*) FROM UnitConversions WHERE ((UnitConversions.FromUnitName LIKE '%' + @search + '%' OR UnitConversions.ToUnitName LIKE '%' + @search + '%' OR UnitConversions.Value LIKE '%' + @search + '%') AND (CompanyId = @filterId))

        SELECT *
        FROM (
                SELECT *,
                    (ROW_NUMBER() OVER(ORDER BY CreatedDate DESC, Id DESC)) AS RowNum
                FROM UnitConversions
                WHERE (FromUnitName LIKE '%' + @search + '%' OR ToUnitName LIKE '%' + @search + '%' OR Value LIKE '%' + @search + '%') AND (CompanyId = @filterId)
            ) AS InvDets
        WHERE InvDets.RowNum BETWEEN @from AND @to
        ORDER BY CreatedDate DESC, InvDets.Id DESC
    END
END
ELSE
BEGIN
    IF (@search IS NULL OR @search = '')
    BEGIN
        SELECT @totalRecordCount = COUNT(*) FROM UnitConversions

        SELECT *
        FROM (
                SELECT *,
                    (ROW_NUMBER() OVER(ORDER BY
                        (CASE
                            WHEN @sortColumn = 1 AND @sortType = 1 THEN FromUnitName
                            WHEN @sortColumn = 2 AND @sortType = 1 THEN ToUnitName
                        END) DESC,
                        (CASE
                            WHEN @sortColumn = 0 AND @sortType = 1 THEN Id
                            WHEN @sortColumn = 3 AND @sortType = 1 THEN Value
                        END) DESC,
                        (CASE
                            WHEN @sortColumn = 1 AND @sortType = 0 THEN id
                            WHEN @sortColumn = 2 AND @sortType = 0 THEN ToUnitName
                        END) ASC,
                        (CASE
                            WHEN @sortColumn = 0 AND @sortType = 0 THEN Id
                            WHEN @sortColumn = 3 AND @sortType = 0 THEN Value
                        END) ASC,
                        CreatedDate DESC
                    )) AS RowNum
                FROM UnitConversions
                WHERE ((FromUnitName LIKE '%' + @search + '%' OR ToUnitName LIKE '%' + @search + '%' OR Value LIKE '%' + @search + '%') AND (CompanyId = @filterId))
            ) AS InvDets
        WHERE RowNum BETWEEN @from AND @to
        ORDER BY
            (CASE
                WHEN @sortColumn = 1 AND @sortType = 1 THEN FromUnitName
                WHEN @sortColumn = 2 AND @sortType = 1 THEN ToUnitName
            END) DESC,
            (CASE
                WHEN @sortColumn = 0 AND @sortType = 1 THEN Id
                WHEN @sortColumn = 3 AND @sortType = 1 THEN Value
            END) DESC,
            (CASE
                WHEN @sortColumn = 1 AND @sortType = 0 THEN FromUnitName
                WHEN @sortColumn = 2 AND @sortType = 0 THEN ToUnitName
            END) ASC,
            (CASE
                WHEN @sortColumn = 0 AND @sortType = 0 THEN Id
                WHEN @sortColumn = 3 AND @sortType = 0 THEN Value
            END) ASC,
            CreatedDate DESC
    END
    ELSE
    BEGIN
        SELECT @totalRecordCount = COUNT(*) FROM UnitConversions WHERE ((UnitConversions.FromUnitName LIKE '%' + @search + '%' OR UnitConversions.ToUnitName LIKE '%' + @search + '%' OR UnitConversions.Value LIKE '%' + @search + '%') AND (CompanyId = @filterId))

        SELECT *
        FROM (
                SELECT *,
                    (ROW_NUMBER() OVER(ORDER BY
                        (CASE
                            WHEN @sortColumn = 1 AND @sortType = 1 THEN FromUnitName
                            WHEN @sortColumn = 2 AND @sortType = 1 THEN ToUnitName
                        END) DESC,
                        (CASE
                            WHEN @sortColumn = 0 AND @sortType = 1 THEN Id
                            WHEN @sortColumn = 3 AND @sortType = 1 THEN Value
                        END) DESC,
                        (CASE
                            WHEN @sortColumn = 1 AND @sortType = 0 THEN FromUnitName
                            WHEN @sortColumn = 2 AND @sortType = 0 THEN ToUnitName
                        END) ASC,
                        (CASE
                            WHEN @sortColumn = 0 AND @sortType = 0 THEN Id
                            WHEN @sortColumn = 3 AND @sortType = 0 THEN Value
                        END) ASC,
                        CreatedDate DESC
                    )) AS RowNum
                FROM UnitConversions
                WHERE (FromUnitName LIKE '%' + @search + '%' OR ToUnitName LIKE '%' + @search + '%' OR Value LIKE '%' + @search + '%') AND (CompanyId = @filterId)
            ) AS InvDets
        WHERE InvDets.RowNum BETWEEN @from AND @to
        ORDER BY
            (CASE
                WHEN @sortColumn = 1 AND @sortType = 1 THEN FromUnitName
                WHEN @sortColumn = 2 AND @sortType = 1 THEN ToUnitName
            END) DESC,
            (CASE
                WHEN @sortColumn = 0 AND @sortType = 1 THEN Id
                WHEN @sortColumn = 3 AND @sortType = 1 THEN Value
            END) DESC,
            (CASE
                WHEN @sortColumn = 1 AND @sortType = 0 THEN FromUnitName
                WHEN @sortColumn = 2 AND @sortType = 0 THEN ToUnitName
            END) ASC,
            (CASE
                WHEN @sortColumn = 0 AND @sortType = 0 THEN Id
                WHEN @sortColumn = 3 AND @sortType = 0 THEN Value
            END) ASC,
            CreatedDate DESC
    END
END

COMMIT TRAN -- Transaction Success!
SET @status = @statusIN;
END TRY
BEGIN CATCH
SET @status = -1;
SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
END CATCH;
END

GO

