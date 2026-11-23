CREATE procedure [dbo].[GetALLBOQPackagesForRate] @ProjectID INT 

AS
BEGIN
 
Select * from BOQPackages   where ProjectId=@ProjectID


END

GO

