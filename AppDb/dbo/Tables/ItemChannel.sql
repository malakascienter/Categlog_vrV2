CREATE TABLE [dbo].[ItemChannel] (
    [Code]        VARCHAR (2)  NOT NULL,
    [Name]        VARCHAR (20) NOT NULL,
    [IsSyncToPos] BIT          NOT NULL,
    [PropertyId]  INT          NOT NULL,
    CONSTRAINT [PK_ItemChannel] PRIMARY KEY CLUSTERED ([Code] ASC, [PropertyId] ASC)
);


GO

