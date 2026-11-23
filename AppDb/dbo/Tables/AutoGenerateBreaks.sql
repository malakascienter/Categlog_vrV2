CREATE TABLE [dbo].[AutoGenerateBreaks] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [AutoGenarateId] INT            NOT NULL,
    [Type]           INT            NOT NULL,
    [TransactionID]  INT            NOT NULL,
    [IPAddress]      NVARCHAR (MAX) NULL,
    [CreatedUserID]  INT            DEFAULT ((0)) NOT NULL,
    [LastModUserID]  INT            DEFAULT ((0)) NOT NULL,
    [CreatedDate]    DATETIME       DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [LastModDate]    DATETIME       DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    CONSTRAINT [PK_dbo.AutoGenerateBreaks] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

