/*
 Post-Deployment Script
 ----------------------
 Runs AFTER the schema is up to date, on every publish.
 Every included script must be safe to run many times (use MERGE / IF NOT EXISTS).
*/

PRINT N'Post-deployment: environment = $(Environment)';

-- Reference/lookup data needed in every environment (including Prod).
:r .\PostDeploy\LookupData.sql

-- Fake sample data: only for Local and Dev databases, never Test or Prod.
IF N'$(Environment)' IN (N'Local', N'Dev')
BEGIN
    :r .\PostDeploy\DevSampleData.sql
END;

-- Record which version was deployed (always last).
:r .\PostDeploy\RecordVersion.sql
