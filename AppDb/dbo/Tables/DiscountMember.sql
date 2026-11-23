CREATE TABLE [dbo].[DiscountMember] (
    [Code]       VARCHAR (10) NOT NULL,
    [MemberCode] VARCHAR (20) CONSTRAINT [DF_Table_1_MemberModulCode] DEFAULT ('') NOT NULL,
    [PropertyId] INT          NOT NULL
);


GO

