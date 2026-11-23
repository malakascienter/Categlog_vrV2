CREATE TABLE [dbo].[INV_DiscountMember] (
    [Id]              BIGINT       IDENTITY (1, 1) NOT NULL,
    [DiscountId]      INT          NOT NULL,
    [DiscountCode]    VARCHAR (10) NOT NULL,
    [MemberCode]      VARCHAR (20) NOT NULL,
    [PropertyId]      INT          NOT NULL,
    [CreatedUserId]   INT          NULL,
    [CreatedDateTime] DATETIME     CONSTRAINT [DF_INV_DiscountMember_Created] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_INV_DiscountMember] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_INV_DiscountMember_Discount]
    ON [dbo].[INV_DiscountMember]([DiscountId] ASC, [PropertyId] ASC)
    INCLUDE([MemberCode]);


GO

