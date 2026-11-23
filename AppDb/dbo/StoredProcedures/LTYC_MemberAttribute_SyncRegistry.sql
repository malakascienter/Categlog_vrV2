
/*  Mirrors one definition into LTYC_SegmentAttribute -- the bridge that makes a
    custom field targetable with no change to the compiler.

    Its own procedure rather than inline in _Save because _Delete needs exactly
    the same thing, and because the expression it writes is the security-relevant
    part of this feature and deserves to be read in one place.

    The code is prefixed CX_ so a custom attribute can never collide with a
    built-in, and so a reader of the registry can see at a glance where a field
    came from.

    Operators are chosen by type, and the list is intentionally narrow:
    everything offered has to make sense against a value stored as text and
    converted on read.                                                           */
CREATE PROCEDURE [dbo].[LTYC_MemberAttribute_SyncRegistry]
    @AttributeId int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Code varchar(50), @Display nvarchar(200), @DataType varchar(20),
            @IsSegmentable bit, @IsPersonalisable bit, @IsActive bit,
            @IsDeleted bit, @SortOrder int, @InputType varchar(20);

    SELECT @Code = AttributeCode, @Display = DisplayName, @DataType = DataType,
           @IsSegmentable = IsSegmentable, @IsPersonalisable = IsPersonalisable,
           @IsActive = IsActive, @IsDeleted = IsDeleted, @SortOrder = SortOrder,
           @InputType = InputType
    FROM   dbo.LTYC_MemberAttribute
    WHERE  AttributeId = @AttributeId;

    IF (@Code IS NULL) RETURN;

    DECLARE @RegistryCode varchar(60) = 'CX_' + @Code;

    /*  The value, converted to the declared type. TRY_CONVERT rather than
        CONVERT throughout: a member whose answer was captured while the field
        was text must not fail the whole segment count when the field is later
        declared numeric -- that one member reads as NULL and drops out of the
        comparison, which is the behaviour every other nullable attribute has.

        `m` is the compiler's alias for LTY_Member, and SourceAlias below is
        MEMBER so no extra join is added. The subquery is correlated to it.      */
    DECLARE @Expression nvarchar(1000) =
        '(SELECT TOP (1) ' +
        CASE @DataType
            WHEN 'INT'     THEN 'TRY_CONVERT(int, cxv.ValueText)'
            WHEN 'DECIMAL' THEN 'TRY_CONVERT(decimal(18,4), cxv.ValueText)'
            WHEN 'DATE'    THEN 'TRY_CONVERT(date, cxv.ValueText)'
            WHEN 'BOOL'    THEN 'TRY_CONVERT(bit, cxv.ValueText)'
            ELSE                'cxv.ValueText'
        END +
        ' FROM dbo.LTYC_MemberAttributeValue AS cxv' +
        ' WHERE cxv.MemberId = m.MemberId AND cxv.AttributeId = ' +
        CONVERT(varchar(12), @AttributeId) + ')';

    /*  A multi-select holds a JSON array, so equality against it would only ever
        match a member who chose exactly one thing in exactly that spelling.
        CONTAINS is the operator that means what a marketer intends -- "has
        Spicy among their choices" -- so it is the one offered.                  */
    DECLARE @Operators varchar(300) =
        CASE
            WHEN @InputType = 'MULTISELECT' THEN 'CONTAINS,IS_NULL,IS_NOT_NULL'
            WHEN @DataType = 'BOOL'         THEN 'IS_TRUE,IS_FALSE,IS_NULL,IS_NOT_NULL'
            WHEN @DataType IN ('INT', 'DECIMAL')
                                            THEN 'EQ,NE,GT,GTE,LT,LTE,BETWEEN,IS_NULL,IS_NOT_NULL'
            WHEN @DataType = 'DATE'         THEN 'EQ,NE,GT,GTE,LT,LTE,BETWEEN,WITHIN_LAST_DAYS,NOT_WITHIN_LAST_DAYS,IS_NULL,IS_NOT_NULL'
            WHEN @DataType = 'ENUM'         THEN 'EQ,NE,IN,NOT_IN,IS_NULL,IS_NOT_NULL'
            ELSE 'EQ,NE,CONTAINS,STARTS_WITH,IN,NOT_IN,IS_NULL,IS_NOT_NULL'
        END;

    -- Live only while the definition is live and still marked segmentable.
    DECLARE @RegistryActive bit =
        CASE WHEN @IsDeleted = 0 AND @IsActive = 1 AND @IsSegmentable = 1 THEN 1 ELSE 0 END;

    IF EXISTS (SELECT 1 FROM dbo.LTYC_SegmentAttribute WHERE AttributeCode = @RegistryCode)
    BEGIN
        UPDATE dbo.LTYC_SegmentAttribute
        SET    DisplayName       = @Display,
               DataType          = CASE WHEN @DataType = 'ENUM' THEN 'STRING' ELSE @DataType END,
               AllowedOperators  = @Operators,
               SqlExpression     = @Expression,
               SourceAlias       = 'MEMBER',
               IsPersonalisable  = @IsPersonalisable,
               SortOrder         = 900 + @SortOrder,
               IsActive          = @RegistryActive
        WHERE  AttributeCode = @RegistryCode;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.LTYC_SegmentAttribute
            (AttributeCode, DisplayName, Category, DataType, AllowedOperators,
             SqlExpression, SourceAlias, IsBrazeSyncable, IsPersonalisable, SortOrder, IsActive)
        VALUES
            (@RegistryCode, @Display, 'PROFILE',
             CASE WHEN @DataType = 'ENUM' THEN 'STRING' ELSE @DataType END,
             @Operators, @Expression, 'MEMBER',
             /*  Not Braze-syncable by default. Pushing a custom field to an
                 external platform is a data-sharing decision, and it is made per
                 attribute in the Braze attribute map rather than assumed here.  */
             0, @IsPersonalisable, 900 + @SortOrder, @RegistryActive);
    END
END

GO

