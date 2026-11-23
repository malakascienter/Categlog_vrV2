CREATE TABLE [dbo].[BOQSecurityAcesses] (
    [ID]        INT            IDENTITY (1, 1) NOT NULL,
    [ProjectID] INT            NOT NULL,
    [BOQID]     NVARCHAR (MAX) NULL,
    [UserID]    INT            NOT NULL,
    [IsAccess]  BIT            NOT NULL,
    [Section]   INT            DEFAULT ((0)) NOT NULL,
    [Work]      INT            DEFAULT ((0)) NOT NULL,
    [Rate]      INT            DEFAULT ((0)) NOT NULL,
    [Level]     INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.BOQSecurityAcesses] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

