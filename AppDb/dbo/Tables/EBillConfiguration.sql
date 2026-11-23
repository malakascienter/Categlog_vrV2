CREATE TABLE [dbo].[EBillConfiguration] (
    [ID]         INT            IDENTITY (1, 1) NOT NULL,
    [Template]   NVARCHAR (MAX) NULL,
    [PropertyId] INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_EBillConfiguration] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

