CREATE TABLE [dbo].[temp_CommonExcelGetData] (
    [Id]       INT            IDENTITY (1, 1) NOT NULL,
    [JsonData] NVARCHAR (MAX) NULL,
    [tranType] VARCHAR (5)    NULL,
    [logDate]  DATETIME       CONSTRAINT [DF_temp_CommonExcelGetData_logDate] DEFAULT (getdate()) NOT NULL
);


GO

