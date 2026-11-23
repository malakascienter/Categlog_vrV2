CREATE TABLE [dbo].[DiscountCustomerGroup] (
    [Id]              BIGINT       IDENTITY (1, 1) NOT NULL,
    [DiscountCode]    VARCHAR (10) NOT NULL,
    [CustomerGroupId] BIGINT       NOT NULL,
    [PropertyId]      INT          NULL
);


GO

