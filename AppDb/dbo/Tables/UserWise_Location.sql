CREATE TABLE [dbo].[UserWise_Location] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [UserID]        INT            NOT NULL,
    [LocationID]    INT            NOT NULL,
    [CompanyId]     INT            NOT NULL,
    [IsActive]      BIT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.UserWise_Location] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IDX_UserWise_Location_UserID]
    ON [dbo].[UserWise_Location]([UserID] ASC)
    INCLUDE([LocationID]);


GO

CREATE NONCLUSTERED INDEX [IDX_UserWise_Location]
    ON [dbo].[UserWise_Location]([UserID] ASC, [LocationID] ASC);


GO

