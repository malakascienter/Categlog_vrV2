CREATE TABLE [dbo].[WB_TaskType] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (MAX) NULL,
    [AutoGenId]        INT            NOT NULL,
    [MyProperty]       NVARCHAR (MAX) NULL,
    [Description]      NVARCHAR (MAX) NULL,
    [Type]             NVARCHAR (MAX) NULL,
    [IsNeedEscalation] BIT            NOT NULL,
    [IPAddress]        NVARCHAR (MAX) NULL,
    [CreatedUserID]    INT            NOT NULL,
    [LastModUserID]    INT            NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    [LastModDate]      DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.WB_TaskType] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

