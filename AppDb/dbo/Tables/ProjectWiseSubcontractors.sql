CREATE TABLE [dbo].[ProjectWiseSubcontractors] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [ProjectID]       INT            NOT NULL,
    [BOQID]           INT            NOT NULL,
    [MainWorkID]      INT            NOT NULL,
    [WorkID]          INT            NOT NULL,
    [SubcontractorID] INT            NOT NULL,
    [Status]          INT            NOT NULL,
    [IPAddress]       NVARCHAR (MAX) NULL,
    [CreatedUserID]   INT            NOT NULL,
    [LastModUserID]   INT            NOT NULL,
    [CreatedDate]     DATETIME       NOT NULL,
    [LastModDate]     DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.ProjectWiseSubcontractors] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

