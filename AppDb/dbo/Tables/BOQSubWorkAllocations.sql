CREATE TABLE [dbo].[BOQSubWorkAllocations] (
    [Id]                  INT             IDENTITY (1, 1) NOT NULL,
    [BOQID]               INT             NOT NULL,
    [Description]         NVARCHAR (MAX)  NULL,
    [Quantity]            DECIMAL (18, 2) NOT NULL,
    [Rate]                DECIMAL (18, 2) NOT NULL,
    [DepartmentID]        INT             NOT NULL,
    [Awarded]             BIT             NOT NULL,
    [SeqNo]               INT             NOT NULL,
    [WorkID]              INT             DEFAULT ((0)) NOT NULL,
    [MainWorkID]          INT             DEFAULT ((0)) NOT NULL,
    [IsPercentageOrValue] BIT             DEFAULT ((0)) NOT NULL,
    [DiscountPercentage]  DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [DiscountValue]       DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [UnitID]              INT             DEFAULT ((0)) NOT NULL,
    [SundryAmount]        DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [OHPValue]            DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_dbo.BOQSubWorkAllocations] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

