CREATE TABLE [dbo].[Temp_ValidateExcelRowData] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [JsonData]      NVARCHAR (MAX) NULL,
    [JsonParamData] NVARCHAR (MAX) NULL,
    [TranType]      VARCHAR (5)    NULL,
    [Name]          VARCHAR (200)  NULL,
    [logDate]       DATETIME       CONSTRAINT [DF_Temp_ValidateExcelRowData_logDate] DEFAULT (getdate()) NOT NULL
);


GO

