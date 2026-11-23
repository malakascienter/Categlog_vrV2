
CREATE   PROCEDURE [dbo].[LTYM_Rewards_SelectEligible]
    @MemberId   INT,
    @Search     NVARCHAR(100) = NULL,
    @Category   VARCHAR(50)   = NULL,
    @Page       INT = 1,
    @PageSize   INT = 20
AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; it comes from the member row.
    DECLARE @PropertyId INT = (SELECT TOP (1) PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);
    IF @Page < 1 SET @Page = 1;
    IF @PageSize < 1 OR @PageSize > 100 SET @PageSize = 20;

    DECLARE @Balance DECIMAL(18,2) = dbo.LTYM_fn_MemberPointsBalance(@MemberId, @PropertyId);

    SELECT R.Id,
           R.Name,
           R.Description,
           R.Category,
           R.PointsCost,
           R.DiscountValue,
           R.IsPercentage,
           R.ValidityDays,
           R.ImagePath,
           CAST(CASE WHEN @Balance >= R.PointsCost THEN 1 ELSE 0 END AS BIT) AS CanAfford
    FROM   dbo.LTYM_Rewards AS R
    WHERE  R.IsActive = 1
      AND (R.StartDate IS NULL OR R.StartDate <= SYSUTCDATETIME())
      AND (R.EndDate   IS NULL OR R.EndDate   >= SYSUTCDATETIME())
      AND (@Search   IS NULL OR R.Name LIKE '%' + @Search + '%' OR R.Description LIKE '%' + @Search + '%')
      AND (@Category IS NULL OR R.Category = @Category)
    ORDER BY R.PointsCost, R.Id
    OFFSET (@Page - 1) * @PageSize ROWS FETCH NEXT @PageSize ROWS ONLY;

    SELECT COUNT(*)
    FROM   dbo.LTYM_Rewards AS R
    WHERE  R.IsActive = 1
      AND (R.StartDate IS NULL OR R.StartDate <= SYSUTCDATETIME())
      AND (R.EndDate   IS NULL OR R.EndDate   >= SYSUTCDATETIME())
      AND (@Search   IS NULL OR R.Name LIKE '%' + @Search + '%' OR R.Description LIKE '%' + @Search + '%')
      AND (@Category IS NULL OR R.Category = @Category);
END

GO

