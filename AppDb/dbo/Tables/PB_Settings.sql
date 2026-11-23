CREATE TABLE [dbo].[PB_Settings] (
    [Code]   VARCHAR (50)  NOT NULL,
    [Value]  VARCHAR (50)  NULL,
    [Remark] VARCHAR (500) NULL,
    CONSTRAINT [PK_PB_Settings] PRIMARY KEY CLUSTERED ([Code] ASC)
);


GO

