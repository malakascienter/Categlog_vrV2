CREATE TABLE [dbo].[POS_OutletWiseMenuItemsRemoveLog] (
    [OutletCode]       VARCHAR (3) NOT NULL,
    [MenuCode]         VARCHAR (4) NOT NULL,
    [IsUpload]         BIT         NULL,
    [PropertyId]       INT         NULL,
    [CreatedUserId]    INT         NULL,
    [CreatedDateTime]  DATETIME    NULL,
    [ModifyUserId]     INT         NULL,
    [ModifiedDateTime] DATETIME    NULL
);


GO

