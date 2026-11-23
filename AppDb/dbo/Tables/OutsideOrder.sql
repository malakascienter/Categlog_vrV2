CREATE TABLE [dbo].[OutsideOrder] (
    [Id]             BIGINT        IDENTITY (1, 1) NOT NULL,
    [OutsideOrderId] VARCHAR (200) CONSTRAINT [DF_OutsideOrder_OutsideOrderId] DEFAULT ('') NOT NULL,
    [AggregatorType] INT           CONSTRAINT [DF_OutsideOrder_AggregatorType] DEFAULT ((0)) NOT NULL,
    [PropertyId]     INT           CONSTRAINT [DF_OutsideOrder_PropertyId] DEFAULT ((0)) NOT NULL,
    [Outlet]         VARCHAR (5)   CONSTRAINT [DF_OutsideOrder_Outlet] DEFAULT ('') NOT NULL,
    [OrderStatus]    VARCHAR (200) CONSTRAINT [DF_OutsideOrder_OrderStatus] DEFAULT ('') NOT NULL,
    [IsUpload]       BIT           CONSTRAINT [DF_OutsideOrder_IsUpload] DEFAULT ((0)) NOT NULL,
    [SysDate]        DATETIME      CONSTRAINT [DF_OutsideOrder_SysDate] DEFAULT (getdate()) NOT NULL,
    [EventDetail]    VARCHAR (MAX) CONSTRAINT [DF_OutsideOrder_EventDetail] DEFAULT ('') NOT NULL
);


GO

