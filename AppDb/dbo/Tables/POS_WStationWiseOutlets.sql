CREATE TABLE [dbo].[POS_WStationWiseOutlets] (
    [POSId]            INT          IDENTITY (1, 1) NOT NULL,
    [ComputerName]     VARCHAR (15) NOT NULL,
    [OutletCode]       VARCHAR (3)  NOT NULL,
    [IsDelete]         BIT          NULL,
    [IsUpload]         BIT          CONSTRAINT [DF_POS_WStationWiseOutlets_IsUpload] DEFAULT ((0)) NOT NULL,
    [PropertyId]       INT          NULL,
    [CreatedUserId]    INT          NULL,
    [CreatedDateTime]  DATETIME     NULL,
    [ModifiedUserId]   INT          NULL,
    [ModifiedDateTime] DATETIME     NULL,
    CONSTRAINT [PK_POS_WStationWiseOutlets] PRIMARY KEY CLUSTERED ([POSId] ASC)
);


GO

