CREATE TABLE [dbo].[BillDetails] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [BillID]        INT             NOT NULL,
    [BOQID]         INT             NOT NULL,
    [WorkDoneID]    INT             NOT NULL,
    [MainWorkID]    INT             NOT NULL,
    [WokeID]        INT             NOT NULL,
    [amount]        DECIMAL (18, 2) NOT NULL,
    [taxVal]        DECIMAL (18, 2) NOT NULL,
    [InvAmount]     DECIMAL (18, 2) NOT NULL,
    [IPAddress]     NVARCHAR (MAX)  NULL,
    [CreatedUserID] INT             NOT NULL,
    [LastModUserID] INT             NOT NULL,
    [CreatedDate]   DATETIME        NOT NULL,
    [LastModDate]   DATETIME        NOT NULL,
    [taxGroupId]    INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.BillDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

