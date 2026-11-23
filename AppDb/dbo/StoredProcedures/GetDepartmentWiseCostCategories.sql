
--GetDepartmentWiseCostCategories 1070,1
CREATE procedure [dbo].[GetDepartmentWiseCostCategories]
@BOQID INT,@DepartmentID INT
As
BEGIN
--SELECT @BOQID BOQID, @DepartmentID DepartmentID INTO AAdata

select DCP.ID,DCP.BOQID,DCP.CategoryId,DCP.DepartmentId,DCP.TotalCost,DCP.BalanceCost,c.Name as CategoryName from [dbo].[DepartmentWiseCostProvisions] as DCP
inner join categories as c on c.id=DCP.categoryid
 where DCP.BOQID=@BOQID and DCP.DepartmentID=@DepartmentID

End

GO

