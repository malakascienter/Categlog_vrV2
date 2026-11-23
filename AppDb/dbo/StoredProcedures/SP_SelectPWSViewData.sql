

CREATE PROCEDURE SP_SelectPWSViewData
	@ProjectID int,
	@BOQID int,
	@SectionID int,
	@WorkID int,
	@SubContractorID int

AS
BEGIN

declare @pwsid int =-1


select @pwsid= pws.Id from ProjectWiseSubcontractors as PWS 
where ProjectID = @ProjectID and BOQID = @BOQID and MainWorkID = @SectionID and WorkID = @WorkID and SubcontractorID = @SubContractorID

if(@pwsid>0)
begin
select PWS.Id, ProjectID, BOQID, MainWorkID, WorkID, SubcontractorID, s.Name as 'SubcontractorName', Status
from ProjectWiseSubcontractors as PWS 
inner join SubContractors as S on PWS.SubcontractorID = s.ID
where ProjectID = @ProjectID and BOQID = @BOQID and MainWorkID = @SectionID and WorkID = @WorkID and SubcontractorID = @SubContractorID


select PWSD.Id, PWSID, UnitDesignatorID, ud.Name as 'UnitDesignatorName', Qty, PWSD.Rate, AdavanceAmount, RetentionsPeriodInMonths, Total
from ProjectWiseSubcontractorsDetails as PWSD 
inner join UnitDesignators as UD on PWSD .UnitDesignatorID = UD.Id
where PWSD.PWSID = @pwsid


select PWSUDB.Id, PWSDetailsID,sh.Name as 'StockItemname', StockItemID, UnitID,u.Name as 'UnitName', PWSUDB.Qty, PWSUDB.Rate, Amount
from SubContractorWiseUnitDesignatorBreakDowns as PWSUDB
inner join ProjectWiseSubcontractorsDetails as PWSD on PWSD.Id = PWSUDB.PWSDetailsID
inner join StockItemHeaders as SH on sh.Id = PWSUDB.StockItemID
inner join Units as U on U.Id = PWSUDB.UnitID
where PWSD.PWSID = @pwsid


select PWSWD.Id, PWSWD.PWSID, PWSDetailsID, DoneQty, PWSWD.Rate, TxnDate, LogDate, StatusID, PaymentRequestSent, PaymentRequestID
from SubContratctorWorkDoneRegistories  as PWSWD
inner join ProjectWiseSubcontractorsDetails as PWSD on PWSD.Id = PWSWD.PWSDetailsID
where PWSD.PWSID = @pwsid 
end



END

GO

