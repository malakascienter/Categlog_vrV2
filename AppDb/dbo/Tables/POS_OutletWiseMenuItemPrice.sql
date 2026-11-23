CREATE TABLE [dbo].[POS_OutletWiseMenuItemPrice] (
    [OutLetWiseMenuItemID] INT             IDENTITY (1, 1) NOT NULL,
    [MenuItemCode]         NVARCHAR (10)   NULL,
    [OutletCode]           NVARCHAR (10)   NULL,
    [PriceTypeID]          INT             NULL,
    [Price]                DECIMAL (18, 5) NULL,
    [IsActive]             BIT             NULL,
    [CreatedUser]          INT             NULL,
    [CreatedDate]          DATETIME        NULL,
    [ModifiedUser]         INT             NULL,
    [ModifiedDate]         DATETIME        NULL,
    [PropertyId]           INT             DEFAULT ((0)) NOT NULL,
    [NewPrice]             DECIMAL (18, 5) DEFAULT ((0)) NOT NULL,
    [EffectiveDate]        DATE            DEFAULT (getdate()) NOT NULL,
    [Id]                   AS              ([OutLetWiseMenuItemID]),
    [WebUpload]            BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_POS_OutletWiseMenuItemPrice] PRIMARY KEY CLUSTERED ([OutLetWiseMenuItemID] ASC)
);


GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER IsUploadChange ON dbo.POS_OutletWiseMenuItemPrice
AFTER INSERT, UPDATE
AS 
BEGIN
	
	UPDATE tb
    SET tb.IsUpload = 0
    FROM MainMenu tb
    INNER JOIN inserted i on i.MenuItemCode = Tb.ItemCode and i.PropertyId = tb.PropertyId
	WHERE tb.ItemCode =  i.MenuItemCode and tb.PropertyId = i.PropertyId


END

GO

