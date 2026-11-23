--select * from BOQSubWorkAllocations
--select * from WorkDetails
--TotalRecalculateBOQ  1
CREATE procedure  [dbo].[TotalRecalculateBOQ] 
@BOQID INT
as
Begin

CREATE TABLE #tmpcal
(
Id INT IDENTITY(1, 1) primary key ,
WorkId INT,
BOQID INT,
RateID int
);

insert into #tmpcal
(WorkId,BOQID,RateID)
select BSW.Id as WorkId,BOQID,WD.RateAnalysisHeaderID as RateID  from BOQSubWorkAllocations as BSW inner join WorkDetails as WD on BSW.Id=WD.WorkID  where BSW.BOQID=@BOQID
 


select * from #tmpcal

while((select count(Id) from #tmpcal) > 0)
begin
declare @Idtemp INT =0;
declare @WorkId INT=0;
declare @RateID INT=0;

select top(1) @Idtemp=Id,@WorkId=WorkId,@RateID=RateID  from #tmpcal



EXEC [dbo].[UpdateRateAllocation] @BOQID,@WorkId,@RateID

delete from #tmpcal where Id=@Idtemp
end

End

GO

