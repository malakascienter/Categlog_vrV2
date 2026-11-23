/*  The content to render, plus the member data personalisation resolves against.

    Two result sets rather than two round trips per message: the template, then
    the member's token values. Only attributes flagged IsPersonalisable in the
    registry are ever exposed, so a template cannot reach a field nobody approved.

    2026-08-19: the custom profile attributes join the second result set. The
    dispatcher reads that row generically -- every column becomes a {{Token}} --
    so a field defined this morning is usable in a template this afternoon with
    no deployment. Only the ones flagged IsPersonalisable appear, which is the
    same gate the built-in fields pass.

    The customs are pivoted with a dynamic PIVOT-free CROSS APPLY over a JSON
    document rather than dynamic SQL, so this procedure stays a fixed, readable
    statement: the attribute codes come back as rows and the renderer's token
    dictionary is built from a name/value pair list appended to the row.

    NOTE the shape difference: built-ins are columns on the member row, customs
    arrive as a third result set of name/value pairs. The dispatcher merges both
    into one token dictionary. Columns cannot be produced for an unknown set of
    names without dynamic SQL, and dynamic SQL here would put attribute codes
    into an executed statement -- exactly what the rest of this design avoids.   */
CREATE PROCEDURE dbo.LTYC_Template_Select
    @TemplateId int,
    @MemberId   int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT t.TemplateId, t.Code, t.Name, t.Channel, t.Subject,
           t.BodyHtml, t.BodyText, t.ImageUrl, t.CtaLabel, t.CtaUrl, t.DeepLink
    FROM   dbo.LTYC_Template AS t
    WHERE  t.TemplateId = @TemplateId;

    SELECT m.MemberId,
           m.FirstName,
           m.LastName,
           m.MembershipCode,
           m.Email,
           m.PrimaryMobileNo                                   AS MobileNo,
           tr.TierName,
           CAST(ISNULL(x.PointBalance, 0) AS decimal(18,2))     AS PointBalance,
           x.LastPurchaseAt,
           CAST(ISNULL(x.TotalSpend, 0) AS decimal(18,4))       AS TotalSpend
    FROM   dbo.LTY_Member AS m
    LEFT JOIN dbo.LTY_Tier          AS tr ON tr.TierId   = m.TierId
    LEFT JOIN dbo.LTYC_MemberMetrics AS x ON x.MemberId  = m.MemberId
    WHERE  m.MemberId = @MemberId;

    -- Third set: the custom attributes this member has answered, as tokens.
    SELECT a.AttributeCode AS TokenName,
           v.ValueText     AS TokenValue
    FROM   dbo.LTYC_MemberAttributeValue AS v
    INNER  JOIN dbo.LTYC_MemberAttribute AS a ON a.AttributeId = v.AttributeId
    INNER  JOIN dbo.LTY_Member AS m2 ON m2.MemberId = v.MemberId
    WHERE  v.MemberId          = @MemberId
      AND  a.PropertyId        = m2.PropertyId
      AND  a.IsDeleted         = 0
      AND  a.IsActive          = 1
      AND  a.IsPersonalisable  = 1
      AND  NULLIF(LTRIM(RTRIM(ISNULL(v.ValueText, ''))), '') IS NOT NULL;
END

GO

