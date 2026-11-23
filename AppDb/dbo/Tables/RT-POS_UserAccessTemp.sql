CREATE TABLE [dbo].[RT-POS_UserAccessTemp] (
    [UserId]          INT      NOT NULL,
    [AccessCodeId]    INT      NOT NULL,
    [PropertyId]      INT      NULL,
    [CreatedUserId]   INT      NULL,
    [CreatedDateTime] DATETIME NULL,
    [UpdatedUserId]   INT      NULL,
    [UpdatedDateTime] DATETIME NULL,
    [IsUpload]        BIT      NULL
);


GO

