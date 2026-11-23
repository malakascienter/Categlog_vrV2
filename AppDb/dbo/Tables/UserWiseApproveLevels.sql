CREATE TABLE [dbo].[UserWiseApproveLevels] (
    [Id]                INT            IDENTITY (1, 1) NOT NULL,
    [PropertyId]        INT            NOT NULL,
    [LocationId]        INT            NOT NULL,
    [TransactionTypeID] INT            NOT NULL,
    [ApproveLevelID]    INT            NOT NULL,
    [UserProfileId]     INT            NOT NULL,
    [CreatedDate]       DATETIME       NOT NULL,
    [CreatedUser]       INT            NOT NULL,
    [ModifiedUser]      INT            NOT NULL,
    [ModifiedDate]      DATETIME       NOT NULL,
    [IPAddress]         NVARCHAR (MAX) NULL,
    [CreatedUserID]     INT            NOT NULL,
    [LastModUserID]     INT            NOT NULL,
    [LastModDate]       DATETIME       NOT NULL,
    [RangeFrom]         DECIMAL (18)   CONSTRAINT [DF_UserWiseApproveLevels_RangeFrom] DEFAULT ((0)) NOT NULL,
    [RangeTo]           DECIMAL (18)   CONSTRAINT [DF_UserWiseApproveLevels_RangeTo] DEFAULT ((0)) NOT NULL,
    [SendEmail]         BIT            CONSTRAINT [DF_UserWiseApproveLevels_SendEmail] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dbo.UserWiseApproveLevels] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

