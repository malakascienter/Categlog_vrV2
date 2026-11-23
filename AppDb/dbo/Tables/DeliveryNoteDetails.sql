CREATE TABLE [dbo].[DeliveryNoteDetails] (
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [DoId]                 INT             NOT NULL,
    [StockItemID]          INT             NOT NULL,
    [InvQuantity]          DECIMAL (18, 2) NOT NULL,
    [Quantity]             DECIMAL (18, 2) NOT NULL,
    [TxnUnitID]            INT             NOT NULL,
    [MasterUnitID]         INT             NOT NULL,
    [MasterUnitConversion] DECIMAL (18, 2) NOT NULL,
    [TimeStamp]            NVARCHAR (256)  NULL,
    [Remarks]              NVARCHAR (MAX)  NULL,
    [UserProfileId]        INT             NOT NULL,
    [TxnType]              NVARCHAR (1)    NULL,
    [IPAddress]            NVARCHAR (MAX)  NULL,
    [CreatedUserID]        INT             NOT NULL,
    [LastModUserID]        INT             NOT NULL,
    [CreatedDate]          DATETIME        NOT NULL,
    [LastModDate]          DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.DeliveryNoteDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

