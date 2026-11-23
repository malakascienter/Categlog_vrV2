CREATE TABLE [dbo].[RequestNotes] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [HeaderID] INT           NOT NULL,
    [Note]     VARCHAR (MAX) NULL,
    [UserId]   INT           NOT NULL
);


GO

