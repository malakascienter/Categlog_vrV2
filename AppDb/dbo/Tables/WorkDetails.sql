CREATE TABLE [dbo].[WorkDetails] (
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [WorkID]               INT             NOT NULL,
    [RateAnalysisHeaderID] INT             NOT NULL,
    [Quantity]             DECIMAL (18, 2) NOT NULL,
    [Rate]                 DECIMAL (18, 2) NOT NULL,
    [IPAddress]            NVARCHAR (MAX)  NULL,
    [CreatedUserID]        INT             NOT NULL,
    [LastModUserID]        INT             NOT NULL,
    [CreatedDate]          DATETIME        NOT NULL,
    [LastModDate]          DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.WorkDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

