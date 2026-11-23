CREATE TABLE [dbo].[Report_ContractedSupplierStatus] (
    [ID]                 INT           NULL,
    [Name]               VARCHAR (MAX) NULL,
    [IsActive]           BIT           NULL,
    [ReportName]         VARCHAR (MAX) NULL,
    [IsReportNameChange] BIT           CONSTRAINT [DF_Report_ContractedSupplierStatus_IsReportNameChange] DEFAULT ((0)) NULL
);


GO

