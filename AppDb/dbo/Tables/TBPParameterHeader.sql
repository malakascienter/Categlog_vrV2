CREATE TABLE [dbo].[TBPParameterHeader] (
    [ID]            INT          IDENTITY (1, 1) NOT NULL,
    [Description]   VARCHAR (50) NULL,
    [IsActive]      BIT          CONSTRAINT [DF_TBPParameterHeader_IsActive] DEFAULT ((0)) NOT NULL,
    [CreatedUserID] INT          NOT NULL,
    [LastModUserID] INT          NOT NULL,
    [CreatedDate]   DATETIME     CONSTRAINT [DF_TBPParameterHeader_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModDate]   DATETIME     CONSTRAINT [DF_TBPParameterHeader_LastModDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_TBPParameterHeader] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

