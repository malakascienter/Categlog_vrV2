/*
 Pre-Deployment Script
 ---------------------
 Runs BEFORE the schema is changed. Use only for things the schema compare
 cannot do on its own, for example backing up data from a column that is
 about to be dropped or changed.

 Every statement here must be safe to run many times (idempotent).
 Use SQLCMD syntax to include files:  :r .\PreDeploy\SomeFile.sql
*/

PRINT N'Pre-deployment: environment = $(Environment)';
