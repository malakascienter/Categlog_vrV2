CREATE TABLE [dbo].[DiscountPayment] (
    [Code]       CHAR (2)    NOT NULL,
    [PayType]    VARCHAR (2) DEFAULT ('') NOT NULL,
    [PropertyId] INT         CONSTRAINT [DF_DiscountPayment_PropertyId] DEFAULT ((0)) NOT NULL
);


GO

