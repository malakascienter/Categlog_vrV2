CREATE TABLE [dbo].[sys_labour] (
    [LaborCode]    VARCHAR (10)  NOT NULL,
    [Description]  VARCHAR (150) NOT NULL,
    [Price]        MONEY         NOT NULL,
    [ComputerName] VARCHAR (50)  NULL,
    [CreateUserId] VARCHAR (50)  NULL,
    [CreateDate]   DATETIME      NULL,
    [costType]     CHAR (10)     NULL
);


GO

