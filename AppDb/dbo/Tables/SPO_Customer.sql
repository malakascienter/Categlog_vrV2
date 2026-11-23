CREATE TABLE [dbo].[SPO_Customer] (
    [ID]             BIGINT          IDENTITY (1, 1) NOT NULL,
    [CustomerTypeID] BIGINT          CONSTRAINT [DF_SPO_Customer_CustomerTypeID] DEFAULT ((0)) NOT NULL,
    [CustomerName]   VARCHAR (250)   CONSTRAINT [DF_Table_1_CustomerCode1] DEFAULT ('') NOT NULL,
    [FullName]       VARCHAR (MAX)   CONSTRAINT [DF_SPO_Customer_FullName] DEFAULT ('') NOT NULL,
    [DateOfBirth]    DATE            CONSTRAINT [DF_SPO_Customer_DateOfBirth] DEFAULT (getdate()) NOT NULL,
    [MobileNumber]   VARCHAR (50)    CONSTRAINT [DF_SPO_Customer_MobileNumber] DEFAULT ('') NOT NULL,
    [Email]          VARCHAR (MAX)   CONSTRAINT [DF_SPO_Customer_Email] DEFAULT ('') NOT NULL,
    [IsEbillRequest] BIT             CONSTRAINT [DF_SPO_Customer_IsEbillRequest] DEFAULT ((0)) NOT NULL,
    [Address]        VARCHAR (MAX)   CONSTRAINT [DF_SPO_Customer_Address] DEFAULT ('') NOT NULL,
    [CreditLimit]    NUMERIC (22, 4) CONSTRAINT [DF_SPO_Customer_CreditLimit] DEFAULT ((0)) NOT NULL,
    [CreditPeriod]   INT             CONSTRAINT [DF_SPO_Customer_CreditLimit1] DEFAULT ((0)) NOT NULL,
    [EmployeeCode]   VARCHAR (50)    CONSTRAINT [DF_SPO_Customer_EmployeeCode] DEFAULT ('') NOT NULL,
    [isActive]       BIT             CONSTRAINT [DF_SPO_Customer_isActive] DEFAULT ((0)) NOT NULL,
    [PropertyId]     INT             DEFAULT ((0)) NOT NULL,
    [DocumentStatus] CHAR (1)        CONSTRAINT [DF_SPO_Customer_DocumentStatus] DEFAULT ('P') NOT NULL
);


GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Number of days', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SPO_Customer', @level2type = N'COLUMN', @level2name = N'CreditPeriod';


GO

