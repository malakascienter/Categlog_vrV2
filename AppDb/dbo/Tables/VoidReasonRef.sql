CREATE TABLE [dbo].[VoidReasonRef] (
    [Void_code]   CHAR (3)     NOT NULL,
    [void_reason] VARCHAR (50) NULL,
    [PropertyId]  INT          NOT NULL,
    CONSTRAINT [PK_VoidReasonRef] PRIMARY KEY CLUSTERED ([Void_code] ASC)
);


GO

