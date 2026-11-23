-- One row per deployment. Filled by Scripts\PostDeploy\RecordVersion.sql.
CREATE TABLE [app].[DbVersion]
(
    [DbVersionId]  INT           IDENTITY (1, 1) NOT NULL,
    [Version]      NVARCHAR (20) NOT NULL,
    [Environment]  NVARCHAR (20) NOT NULL,
    [DeployedBy]   NVARCHAR (128) NOT NULL CONSTRAINT [DF_DbVersion_DeployedBy] DEFAULT (SUSER_SNAME()),
    [DeployedAt]   DATETIME2 (0) NOT NULL CONSTRAINT [DF_DbVersion_DeployedAt] DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT [PK_DbVersion] PRIMARY KEY CLUSTERED ([DbVersionId] ASC)
);
