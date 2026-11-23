CREATE TABLE [dbo].[SPO_OrderWisePayment] (
    [ID]             INT             IDENTITY (1, 1) NOT NULL,
    [OrderId]        INT             NOT NULL,
    [PayCode]        VARCHAR (5)     NOT NULL,
    [PaymentAmount]  DECIMAL (18, 2) NOT NULL,
    [PaymentDate]    DATETIME        NOT NULL,
    [OutletCode]     VARCHAR (5)     NOT NULL,
    [PaymentType]    VARCHAR (2)     NOT NULL,
    [PreviousAmount] DECIMAL (18, 2) CONSTRAINT [DF_SPO_OrderWisePayment_PreviousAmount] DEFAULT ((0)) NOT NULL,
    [BalanceAmount]  DECIMAL (18, 2) CONSTRAINT [DF_SPO_OrderWisePayment_BalanceAmount] DEFAULT ((0)) NOT NULL,
    [Recipet]        VARCHAR (15)    CONSTRAINT [DF_SPO_OrderWisePayment_Recipet] DEFAULT ((0)) NOT NULL,
    [PropertyId]     INT             CONSTRAINT [DF_SPO_OrderWisePayment_PropertyId_1] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_SPO_OrderWisePayment] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

