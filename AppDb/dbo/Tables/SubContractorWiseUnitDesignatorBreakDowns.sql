CREATE TABLE [dbo].[SubContractorWiseUnitDesignatorBreakDowns] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [PWSDetailsID]  INT             NOT NULL,
    [StockItemID]   INT             NOT NULL,
    [UnitID]        INT             NOT NULL,
    [Qty]           DECIMAL (18, 2) NOT NULL,
    [Rate]          DECIMAL (18, 2) NOT NULL,
    [Amount]        DECIMAL (18, 2) NOT NULL,
    [IPAddress]     NVARCHAR (MAX)  NULL,
    [CreatedUserID] INT             NOT NULL,
    [LastModUserID] INT             NOT NULL,
    [CreatedDate]   DATETIME        NOT NULL,
    [LastModDate]   DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.SubContractorWiseUnitDesignatorBreakDowns] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

