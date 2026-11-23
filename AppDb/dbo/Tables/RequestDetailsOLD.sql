CREATE TABLE [dbo].[RequestDetailsOLD] (
    [Id]                INT             IDENTITY (1, 1) NOT NULL,
    [RequestHeaderID]   INT             NOT NULL,
    [StockItemID]       INT             NOT NULL,
    [UnitID]            INT             NOT NULL,
    [RequestedQuantity] DECIMAL (18, 6) NOT NULL,
    [IssuedQuantity]    DECIMAL (18, 6) NOT NULL,
    [ApprovedQuantity]  DECIMAL (18, 6) NOT NULL,
    [Remarks]           NVARCHAR (100)  NULL,
    [TimeStamp]         NVARCHAR (256)  NULL,
    [UnitPrice]         DECIMAL (18, 6) NOT NULL,
    [InvAccountID]      DECIMAL (18, 6) NOT NULL,
    [ItemDeliveryDate]  DATE            NULL,
    CONSTRAINT [PK_dbo.RequestDetailsOLD] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

