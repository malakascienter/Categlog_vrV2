CREATE TABLE [dbo].[temptablepoapproval] (
    [SN]            INT            NOT NULL,
    [Id]            INT            NOT NULL,
    [Approvel]      NVARCHAR (MAX) NULL,
    [Location]      NVARCHAR (MAX) NULL,
    [ReqUserProfId] INT            NULL,
    [ReqUserProf]   VARCHAR (MAX)  NULL,
    [POValue]       VARCHAR (MAX)  NULL,
    [PoNo]          NVARCHAR (50)  NULL,
    [DocumentDate]  DATETIME       NOT NULL,
    [Supplier]      NVARCHAR (100) NULL,
    [Remarks]       NVARCHAR (500) NULL
);


GO

