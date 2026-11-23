CREATE TABLE [dbo].[LineWiseColums] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [LineTypeID]   INT          NULL,
    [ColumnNumber] INT          NULL,
    [FontName]     VARCHAR (50) NULL,
    [Bolt]         BIT          NULL,
    [Italic]       BIT          NULL,
    [Underline]    BIT          NULL,
    [strikeOff]    BIT          NULL,
    [AlignTo]      BIT          NULL,
    [Length]       INT          NULL,
    [DoubleWidth]  BIT          NULL,
    [DoubleHeight] BIT          NULL,
    [Alignment]    VARCHAR (50) NULL
);


GO

