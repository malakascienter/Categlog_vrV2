CREATE TABLE [dbo].[JobHeaders] (
    [ID]             INT            IDENTITY (1, 1) NOT NULL,
    [PropertyID]     INT            NOT NULL,
    [ProjectID]      INT            NOT NULL,
    [BOQID]          INT            NOT NULL,
    [JobCardNumber]  NVARCHAR (MAX) NULL,
    [JobCreateDate]  DATETIME       NOT NULL,
    [CreateUserID]   INT            NOT NULL,
    [Status]         NVARCHAR (MAX) NULL,
    [Complete]       BIT            NOT NULL,
    [Approved]       BIT            NOT NULL,
    [ApprovedUserID] INT            NOT NULL,
    [ApprovedDate]   DATETIME       NOT NULL,
    [LocationID]     INT            NOT NULL,
    [CreateDate]     DATETIME       DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [DepartmentID]   INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.JobHeaders] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

