CREATE TABLE [dbo].[OutSourceLabourDetails] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [HedId]         INT             NOT NULL,
    [DeptId]        INT             NOT NULL,
    [LaborTypeId]   INT             NOT NULL,
    [LaborUnitId]   INT             NOT NULL,
    [Qty]           DECIMAL (18, 2) NOT NULL,
    [Rate]          DECIMAL (18, 2) NOT NULL,
    [Total]         DECIMAL (18, 2) NOT NULL,
    [IPAddress]     NVARCHAR (MAX)  NULL,
    [CreatedUserID] INT             NOT NULL,
    [LastModUserID] INT             NOT NULL,
    [CreatedDate]   DATETIME        NOT NULL,
    [LastModDate]   DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.OutSourceLabourDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

