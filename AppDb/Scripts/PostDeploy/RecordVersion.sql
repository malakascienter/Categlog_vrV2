-- Adds a row only when the version actually changes, so re-publishing the same build is quiet.
IF NOT EXISTS (
    SELECT 1
    FROM   [app].[vw_CurrentVersion]
    WHERE  [Version] = N'$(DacVersion)'
           AND [Environment] = N'$(Environment)'
)
BEGIN
    INSERT INTO [app].[DbVersion] ([Version], [Environment])
    VALUES (N'$(DacVersion)', N'$(Environment)');
END;
