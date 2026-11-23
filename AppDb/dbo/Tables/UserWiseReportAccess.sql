CREATE TABLE [dbo].[UserWiseReportAccess] (
    [Id]                  INT      IDENTITY (1, 1) NOT NULL,
    [UserId]              INT      NULL,
    [RoleId]              INT      NULL,
    [ReportId]            INT      NULL,
    [CreatedUserId]       INT      NULL,
    [CreatedDateTime]     DATETIME NULL,
    [LastUpdatedUserId]   INT      NULL,
    [LastUpdatedDateTime] DATETIME NULL,
    [PropertyId]          INT      NULL,
    CONSTRAINT [PK_UserWiseReportAccess] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

