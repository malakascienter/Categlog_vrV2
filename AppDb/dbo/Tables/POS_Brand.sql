CREATE TABLE [dbo].[POS_Brand] (
    [BrandID]      INT          CONSTRAINT [DF_POS_Brand_BrandID] DEFAULT ((0)) NOT NULL,
    [BrandName]    VARCHAR (50) CONSTRAINT [DF_Table_1_BrandID1] DEFAULT ('') NOT NULL,
    [Sequence]     BIGINT       CONSTRAINT [DF_POS_Brand_Sequence] DEFAULT ((0)) NOT NULL,
    [IsLogoPrint]  BIT          CONSTRAINT [DF_POS_Brand_IsLogoPrint] DEFAULT ((0)) NOT NULL,
    [LogoName]     VARCHAR (50) CONSTRAINT [DF_POS_Brand_LogoName] DEFAULT ('') NOT NULL,
    [LogoPosition] INT          CONSTRAINT [DF_POS_Brand_LogoPosition] DEFAULT ('') NOT NULL
);


GO

