CREATE PROCEDURE [dbo].[SP_SaveCustomer_Signature]
@Id INT,@Path VARCHAR(255),@Name VARCHAR(255),@filename VARCHAR(255)
AS
BEGIN

INSERT INTO dbo.CustomerSignatures
(
    CustomerId,
    CustomerPerson,
    IsFromBasePath,
    ImageFileName,
    ImageFileFullPath
)
VALUES
(   @Id,    -- CustomerId - int
    @Name,  -- CustomerPerson - nvarchar(max)
    1, -- IsFromBasePath - bit
    @filename,  -- ImageFileName - nvarchar(max)
    @Path   -- ImageFileFullPath - nvarchar(max)
    )



END

GO

