CREATE TABLE [dbo].[ActionButtons] (
    [ID]              INT          NOT NULL,
    [Name]            VARCHAR (10) CONSTRAINT [DF_ActionButtons_Name] DEFAULT ('') NOT NULL,
    [AddRate]         BIT          CONSTRAINT [DF_ActionButtons_AddRate] DEFAULT ((0)) NOT NULL,
    [RefItemRequired] BIT          CONSTRAINT [DF_ActionButtons_RefItemRequired] DEFAULT ((0)) NOT NULL
);


GO

