CREATE TABLE [dbo].[DocNos] (
    [DocId]    VARCHAR (5) NOT NULL,
    [NextNo]   INT         CONSTRAINT [DF_DocNos_NextNo_1] DEFAULT ((1)) NOT NULL,
    [AutoNo]   BIT         CONSTRAINT [DF_DocNos_AutoNo] DEFAULT ((1)) NOT NULL,
    [Location] CHAR (3)    NULL
);


GO

