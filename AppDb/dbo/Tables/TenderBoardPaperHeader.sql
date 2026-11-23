CREATE TABLE [dbo].[TenderBoardPaperHeader] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [TBPNumber]    VARCHAR (50)  NULL,
    [Description]  VARCHAR (500) NULL,
    [DepartmentID] INT           NULL,
    [LocationID]   INT           NULL,
    [TxnDate]      DATE          NULL,
    [ExpireDate]   DATE          NULL,
    [RequiredDate] DATE          NULL,
    CONSTRAINT [PK_TenderBoardPaperHeader] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

