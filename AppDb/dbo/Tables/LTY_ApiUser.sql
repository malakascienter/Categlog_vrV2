CREATE TABLE [dbo].[LTY_ApiUser] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [UserName]    VARCHAR (MAX) NOT NULL,
    [Password]    VARCHAR (MAX) NOT NULL,
    [CreatedTime] DATETIME      NOT NULL,
    CONSTRAINT [PK_LTY_ApiUser] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

