CREATE TABLE [dbo].[BOQAmendmentHeader] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [BOQId]          INT            NOT NULL,
    [Remark]         NVARCHAR (MAX) NOT NULL,
    [IPAddress]      NVARCHAR (MAX) NOT NULL,
    [CreatedUserID]  INT            NOT NULL,
    [LastModUserID]  INT            NOT NULL,
    [CreatedDate]    DATE           NOT NULL,
    [LastModDate]    DATE           NOT NULL,
    [ProjectID]      INT            NOT NULL,
    [DocumentNo]     NVARCHAR (MAX) NOT NULL,
    [Approve]        BIT            NOT NULL,
    [ApprovedUserId] INT            NOT NULL,
    [ApprovedDate]   DATE           NOT NULL,
    [DepartmentID]   INT            NOT NULL,
    [LocationID]     INT            NOT NULL,
    CONSTRAINT [PK_BOQAmendmentHeader] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

