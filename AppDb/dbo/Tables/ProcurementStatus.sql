CREATE TABLE [dbo].[ProcurementStatus] (
    [ID]     INT           NOT NULL,
    [Status] CHAR (1)      NULL,
    [Name]   VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

