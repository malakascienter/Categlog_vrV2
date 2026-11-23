CREATE TABLE [dbo].[TBPWiseParameterValues] (
    [TBPParameterDetailID] INT           NOT NULL,
    [Value]                VARCHAR (500) NULL,
    CONSTRAINT [PK_TBPWiseParameterValues] PRIMARY KEY CLUSTERED ([TBPParameterDetailID] ASC)
);


GO

