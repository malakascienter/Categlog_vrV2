CREATE TABLE [dbo].[ProjectWisePricesLogHeader] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [ProjectId]     INT           NOT NULL,
    [Status]        CHAR (2)      NOT NULL,
    [CreatedUserID] INT           NOT NULL,
    [CreatedDate]   DATE          NOT NULL,
    [IPAddress]     NVARCHAR (50) NOT NULL,
    [DocumentNo]    VARCHAR (50)  NOT NULL,
    [Approve]       BIT           NOT NULL,
    CONSTRAINT [PK_ProjectWisePricesLogHeader] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

