CREATE TABLE [dbo].[stockReservation] (
    [Id]           INT  IDENTITY (1, 1) NOT NULL,
    [LocationId]   INT  NOT NULL,
    [ItemHeaderId] INT  NOT NULL,
    [Quantity]     INT  NOT NULL,
    [CreatedUser]  INT  NOT NULL,
    [ModifiedUser] INT  NOT NULL,
    [CreatedDate]  DATE NOT NULL,
    [ModifiedDate] DATE NOT NULL,
    CONSTRAINT [PK_stockTransaction] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

