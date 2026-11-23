CREATE TABLE [dbo].[CommonExcelUploadData] (
    [id]            INT            IDENTITY (1, 1) NOT NULL,
    [jsonData]      NVARCHAR (MAX) NULL,
    [TranType]      VARCHAR (5)    NULL,
    [Date]          DATETIME       CONSTRAINT [DF_CommonExcelUploadData_Date] DEFAULT (getdate()) NOT NULL,
    [jsonParamData] NVARCHAR (MAX) NULL
);


GO

