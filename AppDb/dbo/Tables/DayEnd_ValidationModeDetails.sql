CREATE TABLE [dbo].[DayEnd_ValidationModeDetails] (
    [Id]                INT      IDENTITY (1, 1) NOT NULL,
    [ValidationModeID]  INT      NOT NULL,
    [PropertyID]        INT      NOT NULL,
    [ValidationCheckID] INT      NOT NULL,
    [ItemTemplateID]    INT      NULL,
    [CreatedUserID]     INT      NULL,
    [CreatedDate]       DATETIME CONSTRAINT [DF_DayEnd_VMD_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModUserID]     INT      NULL,
    [LastModDate]       DATETIME NULL,
    CONSTRAINT [PK_DayEnd_ValidationModeDetails] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_DayEnd_VMD_ValidationCheck] FOREIGN KEY ([ValidationCheckID]) REFERENCES [dbo].[DayEnd_ValidationChecks] ([Id]),
    CONSTRAINT [FK_DayEnd_VMD_ValidationMode] FOREIGN KEY ([ValidationModeID]) REFERENCES [dbo].[DayEnd_ValidationModes] ([Id]),
    CONSTRAINT [UQ_DayEnd_VMD_Mode_Property_Check] UNIQUE NONCLUSTERED ([ValidationModeID] ASC, [PropertyID] ASC, [ValidationCheckID] ASC)
);


GO

