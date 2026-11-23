CREATE TABLE [dbo].[RT_Sync_MasterDataTransferStatus] (
    [ID]         INT          IDENTITY (1, 1) NOT NULL,
    [PropertyId] INT          DEFAULT ((0)) NOT NULL,
    [UniqueId]   BIGINT       NULL,
    [Code]       VARCHAR (50) NULL,
    [LocationId] INT          DEFAULT ((0)) NOT NULL,
    [DataType]   VARCHAR (50) DEFAULT ('') NOT NULL,
    [Active]     BIT          DEFAULT ((1)) NOT NULL,
    [Delete]     BIT          DEFAULT ((0)) NOT NULL
);


GO

