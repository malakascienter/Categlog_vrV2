CREATE TABLE [dbo].[POS_OutletWiseMenuItems] (
    [OutletCode]       VARCHAR (3) CONSTRAINT [DF_POS_OutletWiseMenuItems_OutletCode] DEFAULT ('L1') NOT NULL,
    [MenuCode]         VARCHAR (4) CONSTRAINT [DF_POS_OutletWiseMenuItems_MenuCode] DEFAULT ('') NOT NULL,
    [IsUpload]         BIT         NULL,
    [PropertyId]       INT         NULL,
    [CreatedUserId]    INT         NULL,
    [CreatedDateTime]  DATETIME    NULL,
    [ModifyUserId]     INT         NULL,
    [ModifiedDateTime] DATETIME    NULL,
    [WebUpload]        BIT         DEFAULT ((0)) NOT NULL
);


GO

