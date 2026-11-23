CREATE TABLE [dbo].[Temp_POS_OutletWiseMenuItems] (
    [OutletCode]       VARCHAR (3) DEFAULT ('L1') NOT NULL,
    [MenuCode]         VARCHAR (4) DEFAULT ('') NOT NULL,
    [IsUpload]         BIT         NULL,
    [PropertyId]       INT         NULL,
    [CreatedUserId]    INT         NULL,
    [CreatedDateTime]  DATETIME    NULL,
    [ModifyUserId]     INT         NULL,
    [ModifiedDateTime] DATETIME    NULL
);


GO

