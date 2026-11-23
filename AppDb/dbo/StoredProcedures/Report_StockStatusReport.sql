 -- =============================================
-- Author:		Banu
-- ALTER date: 16/11/2018
-- Description:	Report - Consumption(StockStatus)
-- =============================================
------- exec  Report_StockStatusReport '001,002,003,004,005,006,007,020','','','','01/09/2018','11/11/2018'
CREATE procedure [dbo].[Report_StockStatusReport] 
(
	@Outlet varchar(MAX),
	@Category char(6), 
	@SubCategory char(6),
	@Itemcode varchar(16),
	@FromDate varchar(20),
	@ToDate varchar(20)	
)
AS
BEGIN

Declare @Opening money
Declare @Closing money
Declare @Cash money
Declare @Credit money
Declare @Des varchar(250)
Declare @Unit varchar(50)
Declare @Cat varchar(6)
Declare @SubCat varchar(6)
Declare @qty money
declare @CatName varchar(100)
declare @OutletCode varchar(3)
declare @SubCatName as varchar(100)




CREATE TABLE #tmp_Stock  
(
	Opening money,	Closing money, 	Itemcode varchar(16),	IDescription varchar(200),	Unit varchar(20),
	SubCatCode varchar(6),	CatCode varchar(6),AvgPrice money,Cash money,Credit money,	AG money,	GG money,	TI money,	AA money,	SS money,
	To1 money,	II money,	DD money,	P1 money,	PG money,CatName varchar(100), SubCatName varchar(100), PhyQty money, CusRTN money,
	OutletCode varchar(3)
)

CREATE TABLE #tmp_StkTrn  
(
	docid varchar(2),txnid varchar(2),Itemcode varchar(16), quantity money, NewAvg money, NewQty money, StockMasterQty money, IDescription varchar(200),	Unit varchar(20),
	SubCatCode varchar(6),	CatCode varchar(6),AvgPrice money, physicalqty money,  
	 Location varchar(3), date1 datetime,SysDate datetime
)

INSERT INTO #tmp_StkTrn (docid ,txnid,Itemcode, quantity , NewAvg , NewQty , StockMasterQty , 	Unit,
	AvgPrice, physicalqty, CatCode , Location , date1 ,SysDate)
SELECT docid ,txnid,Itemcode, quantity , NewAvg , NewQty , StockMasterQty ,	Unit,
	AvgPrice, physicalqty, CatCode , Location , date1, Sysdate 
FROM stocktransaction
WHERE Location IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
AND(@Category = '' or CatCode = @Category)
AND(@ItemCode = '' or itemcode = @ItemCode)
and date1>=CONVERT(DATETIME,@FromDate,103) 
and date1<=CONVERT(DATETIME,@ToDate,103)


begin transaction

SELECT     ItemNo,[StockMaster].[Description], StockMaster.CategoryCode, StockMaster.Subcatcode, 
		Quantity, [UnitReference].[Description]AS Unit ,CategoryMaster.Description as Category,SubCategoryMaster.description as SubCategory,
		StockMaster.Location,StockMaster.AveragePrice
INTO [#temp] 
FROM StockMaster 
INNER JOIN UnitReference ON StockMaster.Unit = UnitReference.Code
INNER JOIN CategoryMaster ON StockMaster.CategoryCode = CategoryMaster.Code 
INNER JOIN SubCategoryMaster ON SubCategoryMaster.subcatcode = StockMaster.Subcatcode
where Location IN (select * from STRING_SPLIT(@Outlet,',')) 
AND(@Category = '' or CategoryCode = @Category)
AND(@SubCategory = '' or StockMaster.Subcatcode = @SubCategory)
AND(@ItemCode = '' or ItemNo = @ItemCode)




select @Itemcode =itemno,@Des =[Description],@Unit =unit,@Cat =CategoryCode ,@SubCat = Subcatcode,@qty =Quantity
,@CatName=Category, @SubCatName=SubCategory
  from #temp

while @@ROWCOUNT >0

begin

		select top(1) @Opening = StockMasterQty,@OutletCode=Location 
		from #tmp_StkTrn 
		where itemcode =@itemcode order by date1 asc ,Sysdate asc

		if @@ROWCOUNT >0
			begin
		
				select top(1) @Closing = NewQty from #tmp_StkTrn 
				where itemcode =@itemcode  order by date1 desc ,Sysdate desc

				INSERT INTO #tmp_Stock  (Opening,Closing,Itemcode ,IDescription,Unit,SubCatCode,CatCode,AvgPrice,Cash,Credit,AG,GG,TI,AA,SS,To1,II,DD,P1,PG,CatName,SubCatName,PhyQty,CusRTN,OutletCode) 
				select opening ,closing,ItemCode,[description],Unit,Subcatcode,CategoryCode,sum(NewAvg),sum(CashQty),sum(CreditQty), 
					sum(AGQty) as AG, Sum(GGQty) as GG, sum(TIQty) as TI, Sum(AAQTY) as AA ,sum(SSQty) as SS, 
					Sum(TOQty) as TO1, Sum(IIQty) as II ,Sum(DDQty) as DD, sum(P1PQty) as P1 ,Sum(PGQty) as PG ,@CatName as Category, @SubCatName as SubCategory,sum(PhyQty), 
					0 AS CusRTN, OutletCode
					 from
					( SELECT (@Opening) as opening,(@Closing) as closing,
					#tmp_StkTrn.Itemcode, #tmp_StkTrn.NewQty, #tmp_StkTrn.NewAvg, #tmp_StkTrn.StockMasterQty,  #temp.[Description],
					#temp.Unit,#temp.CategoryCode, #temp.Subcatcode,  
					case when #tmp_StkTrn.docid ='A' and #tmp_StkTrn.txnid ='A' then #tmp_StkTrn.quantity else 0 end as AAQty , 
					case when #tmp_StkTrn.docid ='A' and #tmp_StkTrn.txnid ='G' then #tmp_StkTrn.quantity else 0   end as AGQty ,
					case when #tmp_StkTrn.docid ='G' and #tmp_StkTrn.txnid ='G' then #tmp_StkTrn.quantity else 0 end as GGQty ,
					case when #tmp_StkTrn.docid ='S' and #tmp_StkTrn.txnid ='S' then #tmp_StkTrn.quantity else 0 end as SSQty ,
					case when #tmp_StkTrn.docid ='TO' and #tmp_StkTrn.txnid ='TO' then #tmp_StkTrn.quantity else 0 end as TOQty ,
					case when #tmp_StkTrn.docid ='TI' and #tmp_StkTrn.txnid ='G' then #tmp_StkTrn.quantity  else 0 end as TIQty ,
					case when #tmp_StkTrn.docid ='I' and #tmp_StkTrn.txnid ='I' then #tmp_StkTrn.quantity  else 0 end as IIQty ,
					case when #tmp_StkTrn.docid ='D' and #tmp_StkTrn.txnid ='D'  then #tmp_StkTrn.quantity  else 0 end as DDQty ,
					case when #tmp_StkTrn.docid ='P1' and #tmp_StkTrn.txnid ='P'  then #tmp_StkTrn.quantity else 0 end as P1PQty,
					case when #tmp_StkTrn.docid ='P' and #tmp_StkTrn.txnid ='G'  then #tmp_StkTrn.quantity else 0 end as PGQty ,
					----------------------------------------------------------------------------------------------------
					CASE GRNHeader.Cash WHEN 0 THEN 0 WHEN 1 THEN #tmp_StkTrn.quantity ELSE 0 END AS CashQty,
					CASE GRNHeader.Cash WHEN 1 THEN 0 WHEN 0 THEN #tmp_StkTrn.quantity ELSE 0 END AS CreditQty,
					sum(#temp.AveragePrice) AS AvgPrice,sum(#tmp_StkTrn.physicalqty) AS PhyQty, #temp.Location AS OutletCode
				FROM  #temp  
				INNER JOIN #tmp_StkTrn ON #tmp_StkTrn.Location = #temp.Location 
					AND #tmp_StkTrn.Itemcode = #temp.ItemNo 
					-----------------------cash/credit
				LEFT OUTER JOIN GRNHeader ON #tmp_StkTrn.docid = GRNHeader.Docid AND #temp.Location = GRNHeader.Location
				where   #tmp_StkTrn.date1 >=CONVERT(DATETIME,  @FromDate , 103) and 
					#tmp_StkTrn.date1<=CONVERT(DATETIME,@ToDate , 103)  
					and #tmp_StkTrn.Location IN (select * from STRING_SPLIT(@Outlet,','))  and itemcode =@Itemcode 
				GROUP BY #tmp_StkTrn.docid, #tmp_StkTrn.txnid, #tmp_StkTrn.itemcode,#tmp_StkTrn.NewQty, 
					#tmp_StkTrn.NewAvg,#tmp_StkTrn.StockMasterQty , #temp.Description, #temp.unit, #temp.CategoryCode, 
				#temp.Subcatcode, #tmp_StkTrn.quantity,GRNHeader.Cash,#temp.Location ) as aaa GROUP BY Subcatcode,CategoryCode,itemcode,[description],Unit,opening ,closing,OutletCode 

			end
		else
		   begin
				INSERT INTO #tmp_Stock  (Opening,Closing,Itemcode ,IDescription,Unit,SubCatCode,CatCode,AvgPrice,Cash,Credit,AG,GG,TI,AA,SS,To1,II,DD,P1,PG,CatName,SubCatName,PhyQty,CusRTN,OutletCode) 
				values
				(@qty,@qty,@Itemcode,@Des,@Unit,@SubCat,@Cat,0,0,0,0,0,0,0,0,0,0,0,0,0,@CatName,@SubCatName,0,0,@OutletCode)
		   end
		
		Delete from #temp where itemno =@Itemcode 
        select @Itemcode =itemno,@Des =[Description],@Unit =unit,@Cat =CategoryCode ,@SubCat = Subcatcode ,@qty =Quantity ,@CatName=Category, @SubCatName=SubCategory from #temp

        
end
commit transaction
Drop table #temp
select Opening,Closing,Itemcode ,IDescription,Unit,SubCatCode,CatCode,AvgPrice,Cash,Credit,AG,GG,TI,AA,SS,To1,II,DD,P1,PG,CatName,SubCatName,
	(AG-AA) AS Adjust, PhyQty,CusRTN , '' AS Remarks, Location.description AS OutLet
 from #tmp_Stock S
 INNER JOIN Location ON S.OutletCode = Location.code 

 Drop Table #tmp_Stock
end

GO

