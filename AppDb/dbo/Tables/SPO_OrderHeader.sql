CREATE TABLE [dbo].[SPO_OrderHeader] (
    [OrderId]                   INT             IDENTITY (1, 1) NOT NULL,
    [CustomerId]                INT             NOT NULL,
    [MobileNo]                  VARCHAR (15)    NULL,
    [OrderTypeId]               INT             NOT NULL,
    [DeliveryDate]              DATE            NOT NULL,
    [DeliveryTime]              TIME (7)        NOT NULL,
    [DeliveryOutlet]            VARCHAR (50)    NOT NULL,
    [Discount]                  DECIMAL (18, 2) DEFAULT ((0)) NULL,
    [OrderRemark]               VARCHAR (500)   NULL,
    [TotalAmount]               DECIMAL (18, 2) CONSTRAINT [DF_SPO_OrderHeader_TotalAmount] DEFAULT ((0)) NOT NULL,
    [PropertyId]                INT             NOT NULL,
    [Status]                    VARCHAR (20)    DEFAULT ('Pending') NULL,
    [CreatedDate]               DATETIME        DEFAULT (getdate()) NULL,
    [CreatedBy]                 INT             NULL,
    [ModifiedDate]              DATETIME        NULL,
    [ModifiedBy]                INT             NULL,
    [TotalBillDiscountJSON]     NVARCHAR (MAX)  NULL,
    [IsApprove]                 BIT             CONSTRAINT [DF_SPO_OrderHeader_IsApprove] DEFAULT ((0)) NOT NULL,
    [IsOrderCancel]             BIT             CONSTRAINT [DF_SPO_OrderHeader_IsOrderCancel] DEFAULT ((0)) NOT NULL,
    [OrderCancelStatus]         CHAR (1)        CONSTRAINT [DF_SPO_OrderHeader_OrderCancelStatus] DEFAULT ('N') NOT NULL,
    [InvoiceNo]                 NVARCHAR (600)  NULL,
    [AmendCount]                INT             NULL,
    [LastAmendUser]             INT             NULL,
    [LastAmendDate]             DATETIME        CONSTRAINT [DF_SPO_OrderHeader_LastAmendDate] DEFAULT (getdate()) NOT NULL,
    [IsAmend]                   BIT             CONSTRAINT [DF_SPO_OrderHeader_IsAmend] DEFAULT ((0)) NOT NULL,
    [OrderOutlet]               VARCHAR (50)    CONSTRAINT [DF_SPO_OrderHeader_OrderOutlet] DEFAULT ((0)) NOT NULL,
    [NetAmount]                 DECIMAL (18, 2) CONSTRAINT [DF_SPO_OrderHeader_NetAmount] DEFAULT ((0)) NOT NULL,
    [IsItemWiseDiscount]        BIT             CONSTRAINT [DF_SPO_OrderHeader_IsItemWiseDiscount] DEFAULT ((0)) NOT NULL,
    [DocumentChargesPercentage] DECIMAL (18, 2) NULL,
    [RefundAmount]              DECIMAL (18, 2) NULL,
    PRIMARY KEY CLUSTERED ([OrderId] ASC)
);


GO

