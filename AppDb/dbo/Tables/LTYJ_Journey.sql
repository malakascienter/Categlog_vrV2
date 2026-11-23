CREATE TABLE [dbo].[LTYJ_Journey] (
    [JourneyId]        INT             IDENTITY (1, 1) NOT NULL,
    [PropertyId]       INT             NOT NULL,
    [Name]             NVARCHAR (150)  NOT NULL,
    [Description]      NVARCHAR (1000) NULL,
    [Status]           VARCHAR (20)    CONSTRAINT [DF_LTYJ_Journey_Status] DEFAULT ('DRAFT') NOT NULL,
    [CurrentVersionId] INT             NULL,
    [IsDeleted]        BIT             CONSTRAINT [DF_LTYJ_Journey_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]        INT             NOT NULL,
    [CreatedDate]      DATETIME2 (0)   CONSTRAINT [DF_LTYJ_Journey_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    [ModifiedBy]       INT             NULL,
    [ModifiedDate]     DATETIME2 (0)   NULL,
    CONSTRAINT [PK_LTYJ_Journey] PRIMARY KEY CLUSTERED ([JourneyId] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYJ_Journey_Property_Status]
    ON [dbo].[LTYJ_Journey]([PropertyId] ASC, [Status] ASC)
    INCLUDE([Name], [CurrentVersionId]) WHERE ([IsDeleted]=(0));


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_LTYJ_Journey_Property_Name]
    ON [dbo].[LTYJ_Journey]([PropertyId] ASC, [Name] ASC) WHERE ([IsDeleted]=(0));


GO

