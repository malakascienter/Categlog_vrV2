CREATE TABLE [dbo].[POS_UserAccessTemp] (
    [UserId]          VARCHAR (10) CONSTRAINT [DF_POS_UserAccessTemp_UserId] DEFAULT ('') NOT NULL,
    [AccessCodeId]    INT          NOT NULL,
    [PropertyId]      INT          NULL,
    [CreatedUserId]   INT          NULL,
    [CreatedDateTime] DATETIME     NULL,
    [UpdatedUserId]   INT          NULL,
    [UpdatedDateTime] DATETIME     NULL,
    [IsUpload]        BIT          NULL
);


GO

