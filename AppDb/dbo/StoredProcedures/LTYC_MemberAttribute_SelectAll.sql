/*  The definitions, with how many members have answered each one. The count is
    what tells an administrator whether retiring a field would lose data.        */
CREATE PROCEDURE dbo.LTYC_MemberAttribute_SelectAll
    @PropertyId int,
    @IsActive   bit = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT a.AttributeId,
           a.PropertyId,
           a.AttributeCode,
           a.DisplayName,
           a.Description,
           a.DataType,
           a.InputType,
           a.OptionsJson,
           a.IsRequired,
           a.IsSegmentable,
           a.IsPersonalisable,
           a.SortOrder,
           a.IsActive,
           -- What a marketer types into a template to print this field.
           CASE WHEN a.IsPersonalisable = 1 THEN '{{' + a.AttributeCode + '}}' END AS PersonalisationToken,
           -- What it is called in the segment builder's field list.
           CASE WHEN a.IsSegmentable = 1 THEN 'CX_' + a.AttributeCode END AS SegmentAttributeCode,
           (SELECT COUNT(*) FROM dbo.LTYC_MemberAttributeValue AS v
            WHERE v.AttributeId = a.AttributeId
              AND NULLIF(LTRIM(RTRIM(ISNULL(v.ValueText, ''))), '') IS NOT NULL) AS MemberCount,
           a.CreatedDate,
           a.ModifiedDate
    FROM   dbo.LTYC_MemberAttribute AS a
    WHERE  a.PropertyId = @PropertyId
      AND  a.IsDeleted  = 0
      AND  (@IsActive IS NULL OR a.IsActive = @IsActive)
    ORDER BY a.SortOrder, a.DisplayName;
END

GO

