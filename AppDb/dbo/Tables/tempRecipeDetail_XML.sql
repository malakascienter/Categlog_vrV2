CREATE TABLE [dbo].[tempRecipeDetail_XML] (
    [ID]             INT      IDENTITY (1, 1) NOT NULL,
    [logate]         DATETIME DEFAULT (getdate()) NOT NULL,
    [XmlDATA]        XML      NULL,
    [RecipeHeaderID] INT      NULL
);


GO

