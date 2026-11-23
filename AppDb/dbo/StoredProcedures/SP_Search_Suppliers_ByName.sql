-- =============================================
-- Author:		isuru Pramodya
-- Create date: 2025-12-09
-- Description:	Filtering Supplier Details using Name

-- [dbo].[SP_Search_Suppliers_ByName] 'NEO TECH SOLUTIONS',1,1

-- =============================================
CREATE PROCEDURE [dbo].[SP_Search_Suppliers_ByName]
@SupplieName NVARCHAR(MAX),
@LocationId INT,
@propertyID INT
AS
BEGIN
	SET NOCOUNT ON;

    ;WITH KW AS
    (
        SELECT value AS Keyword
        FROM STRING_SPLIT(@SupplieName, ' ')
        WHERE RTRIM(LTRIM(value)) <> ''
    )
	
    SELECT *
    FROM (
	 SELECT DISTINCT S.ID,S.Name,S.Code,
        CASE 
            WHEN S.Name LIKE '%' + @SupplieName + '%' THEN 1   -- Exact phrase
            WHEN NOT EXISTS (
                SELECT 1 
                FROM KW 
                WHERE S.Name NOT LIKE '%' + KW.Keyword + '%'
            ) THEN 2                                              -- All keywords present
            ELSE 3                                                -- Partial matches
        END AS RankOrder

    FROM Suppliers S WITH (NOLOCK)
    WHERE S.IsActive = 1
      AND (
            S.Name LIKE '%' + @SupplieName + '%' 
            OR EXISTS (SELECT 1 FROM KW WHERE S.Name LIKE '%' + KW.Keyword + '%')
          )
    UNION 
    SELECT -888 ID,'--ADD NEW--' Name,'0' Code,999 RankOrder
    ) AS A
    ORDER BY A.RankOrder, A.Name;

    
END

GO

