CREATE TABLE [dbo].[MW_OutsideOrder] (
    [Id]                 INT            IDENTITY (1, 1) NOT NULL,
    [ItemOrderDetailXml] NVARCHAR (MAX) NULL,
    [PropertyId]         INT            NULL,
    [Outlet]             VARCHAR (5)    NULL,
    [OrderType]          VARCHAR (1)    NULL,
    [EventDetail]        NVARCHAR (MAX) NULL,
    [AggregatorId]       INT            NULL,
    [ChannelCode]        VARCHAR (10)   NULL,
    [CreatedDate]        DATETIME       DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

