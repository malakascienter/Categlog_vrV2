CREATE TABLE [dbo].[Companies_Table_Ref] (
    [ColumnName]  VARCHAR (MAX) NULL,
    [Description] VARCHAR (MAX) NULL,
    [AddedDate]   DATETIME      CONSTRAINT [DF_Companies_Table_Ref_AddedDate] DEFAULT (getdate()) NULL,
    [CreatedUser] VARCHAR (MAX) NULL
);


GO

