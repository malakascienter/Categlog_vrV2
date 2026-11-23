CREATE TABLE [dbo].[POS_MainmenuItemWiseImage] (
    [ItemCode]    VARCHAR (12)  NOT NULL,
    [ImageURL]    VARCHAR (MAX) NOT NULL,
    [ImageBinary] IMAGE         NOT NULL,
    [ImageName]   VARCHAR (100) NOT NULL,
    [ImageType]   VARCHAR (20)  NOT NULL,
    [DataType]    VARCHAR (5)   NOT NULL,
    [PropertyId]  INT           NOT NULL
);


GO

