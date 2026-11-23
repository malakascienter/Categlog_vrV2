create PROCEDURE [dbo].[SP_Users]
AS
BEGIN

	select id , username as text  from UserMasters order by text

END

GO

