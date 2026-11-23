CREATE TABLE [dbo].[LTY_MemberWisePointTransaction] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [MemberId]        INT             NOT NULL,
    [NoPoints]        DECIMAL (18, 2) NOT NULL,
    [OutletCode]      VARCHAR (50)    NOT NULL,
    [PropertyId]      INT             NOT NULL,
    [BillValue]       DECIMAL (18, 4) NOT NULL,
    [PointsBefore]    DECIMAL (18, 2) NOT NULL,
    [PointsBalance]   DECIMAL (18, 2) NOT NULL,
    [TransactionType] VARCHAR (10)    NOT NULL,
    [Remark]          VARCHAR (MAX)   NULL,
    [TxnDate]         DATETIME        NOT NULL,
    [CreatedUserId]   INT             NOT NULL,
    [CreatedDateTime] DATETIME        NOT NULL,
    [OrderNo]         VARCHAR (MAX)   NOT NULL,
    [ExpireDate]      DATETIME        NOT NULL,
    CONSTRAINT [PK_LTY_MemberWisePointTransaction] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

