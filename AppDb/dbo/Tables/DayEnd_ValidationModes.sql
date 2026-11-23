CREATE TABLE [dbo].[DayEnd_ValidationModes] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [Code]          NVARCHAR (50) NULL,
    [Name]          VARCHAR (50)  NULL,
    [IsActive]      BIT           CONSTRAINT [DF_DayEnd_ValidationModes_IsActive] DEFAULT ((1)) NOT NULL,
    [IsSystem]      BIT           CONSTRAINT [DF_DayEnd_ValidationModes_IsSystem] DEFAULT ((0)) NOT NULL,
    [CreatedUserID] INT           NULL,
    [CreatedDate]   DATETIME      CONSTRAINT [DF_DayEnd_ValidationModes_CreatedDate] DEFAULT (getdate()) NULL,
    [LastModUserID] INT           NULL,
    [LastModDate]   DATETIME      NULL,
    CONSTRAINT [PK_DayEnd_ValidationModes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_DayEnd_ValidationModes_Code]
    ON [dbo].[DayEnd_ValidationModes]([Code] ASC);


GO

