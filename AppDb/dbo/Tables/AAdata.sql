CREATE TABLE [dbo].[AAdata] (
    [propertyID]    INT            NULL,
    [locationID]    INT            NULL,
    [transactionID] INT            NULL,
    [TH]            INT            NULL,
    [logdate]       DATETIME       CONSTRAINT [DF_AAdata_logdate] DEFAULT (getdate()) NOT NULL,
    [RequestBody]   NVARCHAR (MAX) NULL,
    [ID]            INT            IDENTITY (1, 1) NOT NULL
);


GO

