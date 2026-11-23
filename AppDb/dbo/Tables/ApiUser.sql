CREATE TABLE [dbo].[ApiUser] (
    [Id]          INT          IDENTITY (1, 1) NOT NULL,
    [UserName]    VARCHAR (50) NULL,
    [Password]    VARCHAR (50) NULL,
    [CreatedTime] DATETIME     CONSTRAINT [DF_ApiUser_CreatedTime] DEFAULT (getdate()) NOT NULL
);


GO

