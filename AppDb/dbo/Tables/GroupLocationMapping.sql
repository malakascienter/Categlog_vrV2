CREATE TABLE [dbo].[GroupLocationMapping] (
    [GroupLocationCode]      CHAR (3)      NULL,
    [GroupLocationName]      VARCHAR (30)  NULL,
    [LocationCode]           CHAR (3)      NULL,
    [LocationName]           VARCHAR (30)  NULL,
    [PropertyServer]         VARCHAR (100) CONSTRAINT [DF_GroupLocationMapping_PropertyServer] DEFAULT ('') NOT NULL,
    [PropertyDatabase]       VARCHAR (100) CONSTRAINT [DF_GroupLocationMapping_PropertyDatabase] DEFAULT ('') NOT NULL,
    [PropertyServerUsername] NVARCHAR (50) NULL,
    [PropertyServerPassword] NVARCHAR (50) NULL,
    [IsActive]               BIT           NOT NULL,
    [PropertyId]             INT           DEFAULT ((0)) NOT NULL
);


GO

