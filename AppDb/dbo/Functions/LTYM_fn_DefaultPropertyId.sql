
CREATE   FUNCTION [dbo].[LTYM_fn_DefaultPropertyId] ()
RETURNS INT
AS
BEGIN
    RETURN COALESCE(
        (SELECT MIN(PropertyId) FROM dbo.LTY_Settings),
        (SELECT MIN(PropertyId) FROM dbo.LTY_Member),
        1);
END

GO

