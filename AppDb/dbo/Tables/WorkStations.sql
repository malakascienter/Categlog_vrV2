CREATE TABLE [dbo].[WorkStations] (
    [Computer_Name] VARCHAR (200) NOT NULL,
    [Location]      INT           NOT NULL,
    [Department]    INT           NOT NULL,
    [BillNo]        VARCHAR (50)  NOT NULL,
    [InvoicePrifix] CHAR (2)      NOT NULL,
    [CreateUser]    INT           NOT NULL,
    [CreateDate]    DATETIME      CONSTRAINT [DF_WorkStations_CreateDate] DEFAULT (getdate()) NOT NULL,
    [UpdateUser]    INT           NOT NULL,
    [UpdateDate]    DATETIME      CONSTRAINT [DF_WorkStations_UpdateDate] DEFAULT (getdate()) NOT NULL
);


GO

