CREATE TABLE [dbo].[TBPPrameterDetails] (
    [ID]                   INT          IDENTITY (1, 1) NOT NULL,
    [TBPParameterHeaderID] INT          NOT NULL,
    [Description]          VARCHAR (50) NULL,
    [IsActive]             BIT          CONSTRAINT [DF_TBPPrameterDetails_IsActive] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TBPPrameterDetails] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

