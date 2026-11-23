CREATE TABLE [dbo].[ReportProperties] (
    [Id]                  INT             IDENTITY (1, 1) NOT NULL,
    [CompanyLogo]         VARBINARY (MAX) NULL,
    [Footer]              VARBINARY (MAX) NULL,
    [Copyright]           VARCHAR (MAX)   NULL,
    [CompanyName]         VARCHAR (200)   NULL,
    [CompnyAddress]       VARCHAR (500)   NULL,
    [ContactNo]           VARCHAR (50)    NULL,
    [ContactEmail]        VARCHAR (100)   NULL,
    [BaseCurBankAccTitle] VARCHAR (100)   NULL,
    [BaseCurrAccName]     VARCHAR (100)   NULL,
    [BaseCurrBankName]    VARCHAR (100)   NULL,
    [BaseCurrAccNo]       VARCHAR (50)    NULL,
    [BaseCurrBranch]      VARCHAR (100)   NULL,
    [BaseCurrSwiftCode]   VARCHAR (50)    NULL,
    [FCurBankAccTitle]    VARCHAR (100)   NULL,
    [FCurrAccName]        VARCHAR (100)   NULL,
    [FCurrBankName]       VARCHAR (100)   NULL,
    [FCurrAccNo]          VARCHAR (50)    NULL,
    [FCurrBranch]         VARCHAR (100)   NULL,
    [FCurrSwiftCode]      VARCHAR (50)    NULL,
    [CompPermitNo]        VARCHAR (20)    NULL,
    [PropertyId]          INT             NULL,
    [BaseCurrName]        VARCHAR (50)    DEFAULT ('') NOT NULL,
    [LocalCurrName]       VARCHAR (50)    DEFAULT ('') NOT NULL
);


GO

