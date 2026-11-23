

--GetMainBoq 5
CREATE PROCEDURE GetMainBoq  
@ProjectID INT
AS
Begin

select DISTINCT MainBoqId,Boqcode,ProjectID,Boqname   from BOQHeaders where ProjectID=@ProjectID

End

GO

