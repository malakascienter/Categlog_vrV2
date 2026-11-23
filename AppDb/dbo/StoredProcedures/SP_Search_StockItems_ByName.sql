-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-12-09
-- Description:	Filtering Item Details using Name 

-- [dbo].[SP_Search_StockItems_ByName] 'BUTTER 227GM',1,0

-- =============================================
CREATE PROCEDURE [dbo].[SP_Search_StockItems_ByName]
@SearchKeyWord NVARCHAR(MAX),
@PropertyID INT,
@LocationID INT
AS
BEGIN
	SET NOCOUNT ON;

     ;WITH KW AS
    (
        SELECT value AS Keyword
        FROM STRING_SPLIT(@SearchKeyword, ' ')
        WHERE RTRIM(LTRIM(value)) <> ''
    )
	
    SELECT *
    FROM (
	 SELECT DISTINCT S.ID,S.Name,
        CASE 
            WHEN S.Name LIKE '%' + @SearchKeyword + '%' THEN 1   -- Exact phrase
            WHEN NOT EXISTS (
                SELECT 1 
                FROM KW 
                WHERE S.Name NOT LIKE '%' + KW.Keyword + '%'
            ) THEN 2                                              -- All keywords present
            ELSE 3                                                -- Partial matches
        END AS RankOrder

    FROM StockItemHeaders S WITH (NOLOCK)
    WHERE S.CompanyId = @PropertyID
      AND (
            S.Name LIKE '%' + @SearchKeyword + '%' 
            OR EXISTS (SELECT 1 FROM KW WHERE S.Name LIKE '%' + KW.Keyword + '%')
          )
    UNION 
    SELECT -888 ID,'--ADD NEW--' Name,999 RankOrder
    ) AS A
    ORDER BY A.RankOrder, A.Name;
END

GO

