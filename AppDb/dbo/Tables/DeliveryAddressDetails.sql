CREATE TABLE [dbo].[DeliveryAddressDetails] (
    [DeliveryAddressID] INT            IDENTITY (1, 1) NOT NULL,
    [PropertyID]        INT            NOT NULL,
    [Code]              NVARCHAR (MAX) NULL,
    [Name]              NVARCHAR (MAX) NULL,
    [Address]           NVARCHAR (MAX) NULL,
    [Telephone1]        NVARCHAR (MAX) NULL,
    [Telephone2]        NVARCHAR (MAX) NULL,
    [FaxNo]             NVARCHAR (MAX) NULL,
    [Email]             NVARCHAR (MAX) NULL,
    [ContactPerson]     NVARCHAR (MAX) NULL,
    [IsDefaultAddress]  BIT            NOT NULL,
    CONSTRAINT [PK_dbo.DeliveryAddressDetails] PRIMARY KEY CLUSTERED ([DeliveryAddressID] ASC)
);


GO

