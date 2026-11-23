CREATE TABLE [dbo].[DayeEndSummaryDetail] (
    [Date1]      DATETIME      NOT NULL,
    [PayType]    VARCHAR (100) NULL,
    [No1]        INT           NOT NULL,
    [Amount]     MONEY         NOT NULL,
    [Cash]       CHAR (1)      CONSTRAINT [DF_DayeEndSummaryDetail_Cash] DEFAULT ((0)) NOT NULL,
    [seq]        CHAR (2)      CONSTRAINT [DF_DayeEndSummaryDetail_seq] DEFAULT ((0)) NULL,
    [Outlet]     CHAR (3)      NOT NULL,
    [Upload]     BIT           CONSTRAINT [DF__DayeEndSu__Uploa__60F24029] DEFAULT ((0)) NULL,
    [EmpCode]    CHAR (5)      NULL,
    [PropertyId] INT           NOT NULL
);


GO

