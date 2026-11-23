--SP_SelectBOQViewData 4,2
CREATE PROCEDURE [dbo].[SP_SelectBOQViewData]
	@BoqId INT,
	@UserID INT,
	@CompanyID INT  
AS
BEGIN
	

	select * from BOQMainWorkAllocations where BOQID =@BoqId
	select BWA.Id,BWA.BOQID ,
	         BWA. Description ,
	         BWA. Quantity ,
	         -- Rate+(Quantity*SundryAmount) AS Rate,
			    BWA.Rate+(BWA.SundryAmount+BWA.OHPValue) AS Rate,
	           BWA.DepartmentID ,
	           BWA.Awarded ,
	           BWA.SeqNo ,
	           BWA.WorkID ,
	           BWA.MainWorkID ,
	           BWA.IsPercentageOrValue ,
	           BWA.DiscountPercentage ,
	          BWA.DiscountValue, BWA.UnitID, BWA.SundryAmount as SundryAmount from BOQSubWorkAllocations BWA INNER JOIN dbo.UserWiseDepartments UW ON UW.deptid=BWA.DepartmentID AND UW.userId=@UserID AND UW.companyId=@CompanyID WHERE BOQID =@BoqId




	--select 	MainWorkID ,sw.WorkID,RateAnalysisHeaderID ,WH.Quantity ,WH.Rate  from workdetails as WH inner join BOQSubWorkAllocations as SW 
	--on WH.WorkID = sw.Id where sw.BOQID = @BoqId
	
	select RA.BOQID ,MainWorkID, SW.Id as WorkID , RA.Description,d.Name,RA.RateAnalysisID AS RateID, ProfitMarginPer,ProfitMarginVal	,OverheadCostPer	,OverheadCostVal	,RA.TotalPrice  from   workdetails as WH 
	inner join BOQSubWorkAllocations as SW on WH.WorkID = sw.Id
	inner join dbo.BOQRateanalysisAllocationHeaders as RA on RA.RateAnalysisID = WH.RateAnalysisHeaderID AND RA.WorkID=WH.WorkID inner join Departments as D on sw.DepartmentID=d.Id  where SW.BOQID=@BoqId

	select BM.BOQID,MainWorkID , SUM(Quantity) as Quantity, sum(Rate+(SundryAmount)+ OHPValue) as Rate,
	-- (SUM(Quantity) * sum(Rate+(Quantity*SundryAmount)))  as Total 
	 -- (SUM(Quantity) * sum(Rate+(SundryAmount)))  as Total 
	 sum(BS.Quantity*(BS.Rate+(SundryAmount + BS.OHPValue))) AS Total
	 FROM BOQMainWorkAllocations as BM 
	inner join BOQSubWorkAllocations BS on BM.Id = BS.MainWorkID 
	where bm.BOQID = @BoqId
	group by BM.BOQID,MainWorkID



END

GO

