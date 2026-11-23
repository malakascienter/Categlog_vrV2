CREATE TABLE [dbo].[SPO_CustomerType] (
    [ID]                      BIGINT        IDENTITY (1, 1) NOT NULL,
    [CustomerTypeName]        VARCHAR (MAX) CONSTRAINT [DF_SPO_CustomerType_CustomerTypeName] DEFAULT ('') NOT NULL,
    [IsActive]                BIT           CONSTRAINT [DF_SPO_CustomerType_isActive] DEFAULT ((0)) NOT NULL,
    [PropertyId]              INT           NOT NULL,
    [CreatedUserId]           INT           CONSTRAINT [DF_SPO_CustomerType_CreatedUserId] DEFAULT ((0)) NOT NULL,
    [CreatedDatetime]         DATETIME      CONSTRAINT [DF_SPO_CustomerType_CreatedDatetime] DEFAULT (getdate()) NOT NULL,
    [LastEditedUserId]        INT           CONSTRAINT [DF_SPO_CustomerType_LastEditedUserId] DEFAULT ((0)) NOT NULL,
    [LastEditedDateTime]      DATETIME      CONSTRAINT [DF_SPO_CustomerType_LastEditedDateTime] DEFAULT (getdate()) NOT NULL,
    [isEnableCompanyDetails]  BIT           DEFAULT ((0)) NOT NULL,
    [isEnableEmployeeDetails] BIT           DEFAULT ((0)) NOT NULL,
    [isEnableCreditDetails]   BIT           DEFAULT ((0)) NOT NULL,
    [IsCustomerApprove]       BIT           CONSTRAINT [DF_SPO_CustomerType_IsCustomerApprove] DEFAULT ((0)) NOT NULL
);


GO

