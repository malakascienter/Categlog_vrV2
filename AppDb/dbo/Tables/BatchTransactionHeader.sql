CREATE TABLE [dbo].[BatchTransactionHeader] (
    [Id]            INT          IDENTITY (1, 1) NOT NULL,
    [DocNo]         VARCHAR (20) NULL,
    [PropertyID]    INT          NULL,
    [CreatedUserID] INT          NULL,
    [CreatedDate]   DATETIME     NULL,
    [LocationID]    INT          CONSTRAINT [DF_BatchTransactionHeader_LocationID] DEFAULT ((-999)) NULL,
    [SupplierID]    INT          CONSTRAINT [DF_BatchTransactionHeader_SupplierID] DEFAULT ((-999)) NULL
);


GO

