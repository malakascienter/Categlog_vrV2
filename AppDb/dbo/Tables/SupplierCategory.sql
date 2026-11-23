CREATE TABLE [dbo].[SupplierCategory] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [SupplierCategoryCode] VARCHAR (255) NOT NULL,
    [SupplierCategoryName] VARCHAR (255) NOT NULL,
    [IsActive]             BIT           NOT NULL,
    [CreatedUserID]        INT           NOT NULL,
    [LastModUserID]        INT           NULL,
    [CreatedDate]          DATETIME      NOT NULL,
    [LastModDate]          DATETIME      NULL,
    CONSTRAINT [PK_SupplierCategory] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

