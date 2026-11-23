
--GetMainBoq 5
CREATE procedure [dbo].[SP_GetFinalizedBoqs]  
@ProjectID INT
AS
Begin

select DISTINCT Id,Boqcode,ProjectID,Boqname   from BOQHeaders where ProjectID=@ProjectID AND Approve=1 AND Finalized=1

End

GO

