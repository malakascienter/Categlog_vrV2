CREATE TABLE [dbo].[POS_ItemsBarCode] (
    [PropertyId]       INT          NULL,
    [MenuCode]         VARCHAR (4)  NOT NULL,
    [BarCode]          VARCHAR (20) NOT NULL,
    [IsUpload]         BIT          NULL,
    [CreatedUserId]    INT          NULL,
    [CreatedDateTime]  DATETIME     NULL,
    [ModifyUserId]     INT          NULL,
    [ModifiedDateTime] DATETIME     NULL
);


GO

