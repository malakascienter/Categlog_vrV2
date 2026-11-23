
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetAllClients]

AS
BEGIN

	--SELECT * FROM dbo.Clients
	SELECT Id,CustomerName AS Name,AddLine1 AS Address,Tele1 AS Tel,Email1 AS Email,ContactPerson01 AS ConPer,
	Fax,1 AS TaxGroupID,IPAddress,CreatedUserID,LastModUserID,CreatedDate,LastModDate FROM dbo.Customers

END

GO

