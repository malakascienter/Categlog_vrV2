CREATE TABLE [dbo].[SPO_UserWiseApproveLevels] (
    [Id]                INT      IDENTITY (1, 1) NOT NULL,
    [PropertyId]        INT      NOT NULL,
    [LocationId]        CHAR (5) NOT NULL,
    [TransactionTypeID] INT      NOT NULL,
    [ApproveTypeID]     INT      NOT NULL,
    [UserProfileId]     INT      NOT NULL,
    [CreatedUserID]     INT      NOT NULL,
    [LastModUserID]     INT      NOT NULL,
    [CreatedDate]       DATETIME CONSTRAINT [DF_SPO_UserWiseApproveLevels_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedDate]      DATETIME CONSTRAINT [DF_SPO_UserWiseApproveLevels_ModifiedDate] DEFAULT (getdate()) NOT NULL
);


GO

