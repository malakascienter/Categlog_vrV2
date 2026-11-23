CREATE TABLE [dbo].[UserWiseOutlet] (
    [Id]                  INT           IDENTITY (1, 1) NOT NULL,
    [UserId]              INT           NOT NULL,
    [OutletCode]          NVARCHAR (50) NOT NULL,
    [IsActive]            BIT           CONSTRAINT [DF_UserWiseOutlet_IsActive] DEFAULT ((1)) NOT NULL,
    [IsUpload]            BIT           NULL,
    [PropertyId]          INT           NULL,
    [CreatedUserId]       INT           NULL,
    [CreatedDateTime]     DATETIME      NOT NULL,
    [LastUpdatedUserId]   INT           NULL,
    [LastUpdatedDateTime] DATETIME      NULL,
    CONSTRAINT [PK_UserWiseProperties] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

