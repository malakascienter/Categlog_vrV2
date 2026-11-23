CREATE TABLE [dbo].[UserProfiles] (
    [Id]                   INT            IDENTITY (1, 1) NOT NULL,
    [UserName]             NVARCHAR (MAX) NULL,
    [Password]             NVARCHAR (MAX) NULL,
    [FirstName]            NVARCHAR (MAX) NULL,
    [LastName]             NVARCHAR (MAX) NULL,
    [CommunicationTypeID1] NVARCHAR (MAX) NULL,
    [CommunicationTypeID2] NVARCHAR (MAX) NULL,
    [CommunicationTypeID3] NVARCHAR (MAX) NULL,
    [CommunicationTypeID4] NVARCHAR (MAX) NULL,
    [ContactValue1]        NVARCHAR (MAX) NULL,
    [ContactValue2]        NVARCHAR (MAX) NULL,
    [ContactValue3]        NVARCHAR (MAX) NULL,
    [ContactValue4]        NVARCHAR (MAX) NULL,
    [IsActive]             BIT            NOT NULL,
    [IPAddress]            NVARCHAR (MAX) NULL,
    [CreatedUserID]        INT            NOT NULL,
    [LastModUserID]        INT            NOT NULL,
    [CreatedDate]          DATETIME       NOT NULL,
    [LastModDate]          DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.UserProfiles] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

