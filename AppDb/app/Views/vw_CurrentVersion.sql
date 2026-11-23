-- SELECT * FROM app.vw_CurrentVersion;  -> shows which release this database is on.
CREATE VIEW [app].[vw_CurrentVersion]
AS
SELECT TOP (1)
       [Version],
       [Environment],
       [DeployedBy],
       [DeployedAt]
FROM   [app].[DbVersion]
ORDER  BY [DbVersionId] DESC;
