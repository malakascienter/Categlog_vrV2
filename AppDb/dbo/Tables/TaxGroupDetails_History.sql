CREATE TABLE [dbo].[TaxGroupDetails_History] (
    [TaxGroupDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [TaxGroupId]       INT             NOT NULL,
    [TaxTypeId]        INT             NOT NULL,
    [SortSequance]     INT             NOT NULL,
    [IsActive]         BIT             NOT NULL,
    [ChargeRate]       DECIMAL (18, 4) NOT NULL,
    [IPAddress]        NVARCHAR (MAX)  NULL,
    [CreatedUserID]    INT             NOT NULL,
    [LastModUserID]    INT             NOT NULL,
    [CreatedDate]      DATETIME        NOT NULL,
    [LastModDate]      DATETIME        NOT NULL,
    [ValidateFromDate] DATETIME        NOT NULL,
    [ValidateToDate]   DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.TaxGroupDetails_History] PRIMARY KEY CLUSTERED ([TaxGroupDetailId] ASC)
);


GO

