CREATE TABLE [dbo].[Sync_MasterDataTransferStatus] (
    [ID]         BIGINT       IDENTITY (1, 1) NOT NULL,
    [PropertyId] INT          NULL,
    [Code]       VARCHAR (10) NULL,
    [Outlet]     VARCHAR (50) CONSTRAINT [DF__Sync_Mast__Outle__0BD09AFB] DEFAULT ('L1') NOT NULL,
    [DataType]   VARCHAR (50) CONSTRAINT [DF__Sync_Mast__DataT__0CC4BF34] DEFAULT ('') NOT NULL,
    [Active]     BIT          CONSTRAINT [DF__Sync_Mast__Activ__0DB8E36D] DEFAULT ((1)) NOT NULL
);


GO

