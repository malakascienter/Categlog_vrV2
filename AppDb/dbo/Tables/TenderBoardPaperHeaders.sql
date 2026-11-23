CREATE TABLE [dbo].[TenderBoardPaperHeaders] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [TBPNumber]     NVARCHAR (MAX) NULL,
    [Description]   NVARCHAR (MAX) NULL,
    [DepartmentID]  INT            NOT NULL,
    [LocationID]    INT            NOT NULL,
    [TxnDate]       DATETIME       NOT NULL,
    [ExpireDate]    DATETIME       NOT NULL,
    [RequiredDate]  DATETIME       NOT NULL,
    [CompanyID]     INT            DEFAULT ((0)) NOT NULL,
    [Status]        INT            DEFAULT ((0)) NOT NULL,
    [InSequence]    INT            DEFAULT ((0)) NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            DEFAULT ((0)) NOT NULL,
    [LastModUserID] INT            DEFAULT ((0)) NOT NULL,
    [CreatedDate]   DATETIME       DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [LastModDate]   DATETIME       DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [BaseType]      INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.TenderBoardPaperHeaders] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

