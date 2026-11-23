-- =============================================
-- Author:		Nivesh
-- Create date: 2026-01-13
-- Description:	Delete re-order email
-- =============================================
CREATE     PROCEDURE [dbo].[SP_SaveReOrderLocationWiseEmail] 
	-- Add the parameters for the stored procedure here
	@Id INT = 0,
	@CompanyId INT,
	@JsonString NVARCHAR(MAX) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 
     DECLARE 
         @EmailList NVARCHAR(MAX),
         @IsActive BIT;
     
     DECLARE  @TempEmailList TABLE(
      Email NVARCHAR(200),
      IsActive BIT
     )
	
    INSERT INTO @TempEmailList(
        Email,
        IsActive
    )
    SELECT DISTINCT 
        Email,
        IsActive
    FROM OPENJSON(@JsonString)
    WITH
    (
        Email NVARCHAR(200) '$.Email',
        IsActive BIT '$.IsActive'
    )

    SELECT @EmailList = STRING_AGG(Email, ','),
    @IsActive = IsActive
    FROM
    @TempEmailList
    GROUP BY IsActive

	IF EXISTS (SELECT 1 FROM ReOrderLocationWiseEmail WHERE LocationID = @Id AND CompanyID = @CompanyId)
    BEGIN
        UPDATE ReOrderLocationWiseEmail
        SET 
            EmailList = @EmailList,
            IsActive = ISNULL(@IsActive,0)
        WHERE LocationID = @Id
        AND CompanyID = @CompanyId;
    END
    ELSE
    BEGIN
        IF @EmailList IS NOT NULL 
        BEGIN
            INSERT INTO ReOrderLocationWiseEmail (LocationID,CompanyID, EmailList,IsActive)
            VALUES (@Id,@CompanyId, @EmailList,@IsActive);
        END
    END
END

GO

