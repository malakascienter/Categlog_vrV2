CREATE procedure [dbo].[GetALLBOQPackages] @ProjectID INT 

AS
BEGIN
 
Select * from BOQPackages  WHERE ProjectID =@ProjectID


END

GO

