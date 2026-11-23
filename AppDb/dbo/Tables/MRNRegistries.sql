CREATE TABLE [dbo].[MRNRegistries] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [RequestionID]  INT            NOT NULL,
    [IssueID]       INT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            DEFAULT ((0)) NOT NULL,
    [LastModUserID] INT            DEFAULT ((0)) NOT NULL,
    [CreatedDate]   DATETIME       DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [LastModDate]   DATETIME       DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [DocNo]         NVARCHAR (MAX) NULL,
    [ProjectID]     INT            DEFAULT ((0)) NOT NULL,
    [BoqID]         INT            DEFAULT ((0)) NOT NULL,
    [Status]        BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.MRNRegistries] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

