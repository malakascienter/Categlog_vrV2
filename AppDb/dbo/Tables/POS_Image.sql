CREATE TABLE [dbo].[POS_Image] (
    [Code]       VARCHAR (10)  NOT NULL,
    [DataType]   VARCHAR (3)   CONSTRAINT [DF_POS_Image_Type] DEFAULT ('') NOT NULL,
    [ItemImage]  IMAGE         NULL,
    [PropertyId] INT           DEFAULT ((0)) NOT NULL,
    [ImageName]  VARCHAR (100) DEFAULT ('no-image.png') NOT NULL
);


GO

