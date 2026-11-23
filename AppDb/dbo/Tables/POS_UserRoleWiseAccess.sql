CREATE TABLE [dbo].[POS_UserRoleWiseAccess] (
    [UserRoleId]      VARCHAR (10) DEFAULT ('') NOT NULL,
    [AccessCodeId]    INT          NOT NULL,
    [PropertyId]      INT          NULL,
    [CreatedUserId]   INT          NULL,
    [CreatedDateTime] DATETIME     NULL,
    [UpdatedUserId]   INT          NULL,
    [UpdatedDateTime] DATETIME     NULL,
    [IsUpload]        BIT          NULL
);


GO

