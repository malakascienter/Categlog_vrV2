/*  Every property that has members.

    The metrics rollup is per-property - its watermark is keyed on PropertyId -
    so a worker that is not pinned to one tenant has to iterate. Derived from
    LTY_Member rather than from a property master table, because a property with
    no members has nothing to roll up and would only add an empty pass.          */
CREATE PROCEDURE dbo.LTYC_Property_SelectAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT PropertyId
    FROM   dbo.LTY_Member
    ORDER BY PropertyId;
END

GO

