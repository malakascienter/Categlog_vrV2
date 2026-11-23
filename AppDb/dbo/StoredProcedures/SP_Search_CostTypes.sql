CREATE PROCEDURE [dbo].[SP_Search_CostTypes]
    --SELECT * FROM CostTypes
    @from INT,
    @to INT,
    @search VARCHAR(20),
    @sortType INT,
    @sortColumn INT,
    @totalRecordCount INT OUTPUT,
    @status INT OUTPUT,
    @message VARCHAR(20) OUTPUT
    --@filterId INT
AS
DECLARE @statusIN [INT];
SET @statusIN = 0;
SET @message = '';

BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        SET @search = LTRIM(RTRIM(@search));

        IF (@sortColumn = 0 AND @sortType = 0)
        BEGIN
            IF (@search IS NULL OR @search = '')
            BEGIN
                SELECT @totalRecordCount = COUNT(*)
                FROM CostTypes;

                SELECT *
                FROM
                (
                    SELECT *,
                           (ROW_NUMBER() OVER (ORDER BY Id ASC)) AS RowNum
                    FROM CostTypes
                    WHERE (
                              Id LIKE '%' + @search + '%'
                              OR Description LIKE '%' + @search + '%'
                              OR Code LIKE '%' + @search + '%'
                          )
                ) AS InvDets
                WHERE RowNum
                BETWEEN @from AND @to
                ORDER BY Id ASC;
            END;

            ELSE
            BEGIN

                SELECT @totalRecordCount = COUNT(*)
                FROM CostTypes
                WHERE (
                          CostTypes.Id LIKE '%' + @search + '%'
                          OR CostTypes.Code LIKE '%' + @search + '%'
                          OR CostTypes.Description LIKE '%' + @search + '%'
                      );

                SELECT *
                FROM
                (
                    SELECT *,
                           (ROW_NUMBER() OVER (ORDER BY Id ASC)) AS RowNum
                    FROM CostTypes
                    WHERE Id LIKE '%' + @search + '%'
                          OR Description LIKE '%' + @search + '%'
                          OR Code LIKE '%' + @search + '%'
                ) AS InvDets
                WHERE InvDets.RowNum
                BETWEEN @from AND @to
                ORDER BY InvDets.Id ASC;
            END;
        END;

        ELSE
        BEGIN

            IF (@search IS NULL OR @search = '')
            BEGIN
                SELECT @totalRecordCount = COUNT(*)
                FROM CostTypes;

                SELECT *
                FROM
                (
                    SELECT *,
                           (ROW_NUMBER() OVER (ORDER BY (CASE
                                                             WHEN @sortColumn = 2
                                                                  AND @sortType = 1 THEN
                                                                 Description
                                                             WHEN @sortColumn = 1
                                                                  AND @sortType = 1 THEN
                                                                 Code
                                                         END
                                                        ) DESC,
                                                        (CASE
                                                             WHEN @sortColumn = 0
                                                                  AND @sortType = 1 THEN
                                                                 Id
                                                         END
                                                        ) DESC,
                                                        (CASE
                                                             WHEN @sortColumn = 2
                                                                  AND @sortType = 0 THEN
                                                                 Description
                                                             WHEN @sortColumn = 1
                                                                  AND @sortType = 0 THEN
                                                                 Code
                                                         END
                                                        ) ASC,
                                                        (CASE
                                                             WHEN @sortColumn = 0
                                                                  AND @sortType = 0 THEN
                                                                 Id
                                                         END
                                                        ) ASC
                                              )
                           ) AS RowNum
                    FROM CostTypes
                    WHERE (
                              Id LIKE '%' + @search + '%'
                              OR Description LIKE '%' + @search + '%'
                              OR Code LIKE '%' + @search + '%'
                          )
                ) AS InvDets
                WHERE RowNum
                BETWEEN @from AND @to
                ORDER BY (CASE
                              WHEN @sortColumn = 2
                                   AND @sortType = 1 THEN
                                  Description
                              WHEN @sortColumn = 1
                                   AND @sortType = 1 THEN
                                  Code
                          END
                         ) DESC,
                         (CASE
                              WHEN @sortColumn = 0
                                   AND @sortType = 1 THEN
                                  Id
                          END
                         ) DESC,
                         (CASE
                              WHEN @sortColumn = 2
                                   AND @sortType = 0 THEN
                                  Description
                              WHEN @sortColumn = 1
                                   AND @sortType = 0 THEN
                                  Code
                          END
                         ) ASC,
                         (CASE
                              WHEN @sortColumn = 0
                                   AND @sortType = 0 THEN
                                  Id
                          END
                         ) ASC;
            END;

            ELSE
            BEGIN

                SELECT @totalRecordCount = COUNT(*)
                FROM CostTypes
                WHERE (
                          CostTypes.Id LIKE '%' + @search + '%'
                          OR CostTypes.Description LIKE '%' + @search + '%'
                          OR CostTypes.Code LIKE '%' + @search + '%'
                      );

                SELECT *
                FROM
                (
                    SELECT *,
                           (ROW_NUMBER() OVER (ORDER BY (CASE
                                                             WHEN @sortColumn = 2
                                                                  AND @sortType = 1 THEN
                                                                 Description
                                                             WHEN @sortColumn = 1
                                                                  AND @sortType = 1 THEN
                                                                 Code
                                                         END
                                                        ) DESC,
                                                        (CASE
                                                             WHEN @sortColumn = 0
                                                                  AND @sortType = 1 THEN
                                                                 Id
                                                         END
                                                        ) DESC,
                                                        (CASE
                                                             WHEN @sortColumn = 2
                                                                  AND @sortType = 0 THEN
                                                                 Description
                                                             WHEN @sortColumn = 1
                                                                  AND @sortType = 0 THEN
                                                                 Code
                                                         END
                                                        ) ASC,
                                                        (CASE
                                                             WHEN @sortColumn = 0
                                                                  AND @sortType = 0 THEN
                                                                 Id
                                                         END
                                                        ) ASC
                                              )
                           ) AS RowNum
                    FROM CostTypes
                    WHERE Id LIKE '%' + @search + '%'
                          OR Description LIKE '%' + @search + '%'
                          OR Code LIKE '%' + @search + '%'
                ) AS InvDets
                WHERE InvDets.RowNum
                BETWEEN @from AND @to
                ORDER BY (CASE
                              WHEN @sortColumn = 2
                                   AND @sortType = 1 THEN
                                  Description
                              WHEN @sortColumn = 1
                                   AND @sortType = 1 THEN
                                  Code
                          END
                         ) DESC,
                         (CASE
                              WHEN @sortColumn = 0
                                   AND @sortType = 1 THEN
                                  Id
                          END
                         ) DESC,
                         (CASE
                              WHEN @sortColumn = 2
                                   AND @sortType = 0 THEN
                                  Description
                              WHEN @sortColumn = 1
                                   AND @sortType = 0 THEN
                                  Code
                          END
                         ) ASC,
                         (CASE
                              WHEN @sortColumn = 0
                                   AND @sortType = 0 THEN
                                  Id
                          END
                         ) ASC;
            END;

        END;
        COMMIT TRAN; -- Transaction Success!
        SET @status = @statusIN;
    END TRY
    BEGIN CATCH
        SET @status = -1;
        SET @message
            = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line '
              + CAST(ERROR_LINE() AS VARCHAR(10));
    END CATCH;
END;

GO

