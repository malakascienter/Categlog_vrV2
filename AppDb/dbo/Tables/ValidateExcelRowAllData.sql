CREATE TABLE [dbo].[ValidateExcelRowAllData] (
    [Id]                                     INT            IDENTITY (1, 1) NOT NULL,
    [JsonData]                               NVARCHAR (MAX) NULL,
    [JsonActiveNames]                        NVARCHAR (MAX) NULL,
    [JsonFilterValidColumnConfigurationData] NVARCHAR (MAX) NULL,
    [paramsData]                             NVARCHAR (MAX) NULL,
    [TransactionType]                        VARCHAR (5)    NULL,
    [Name]                                   VARCHAR (100)  NULL,
    [logDate]                                DATETIME       CONSTRAINT [DF_ValidateExcelRowAllData_logDate] DEFAULT (getdate()) NOT NULL
);


GO

