CREATE TABLE [dbo].[tempProductionXML] (
    [ID]      INT      IDENTITY (1, 1) NOT NULL,
    [logate]  DATETIME DEFAULT (getdate()) NOT NULL,
    [XmlDATA] XML      NULL
);


GO

